#!/usr/bin/env bash
#
# Fast, dependency-light machine guards.
#
# These are cross-cutting invariants that are cheaper to check with a script
# than to remember as prose. Each guard prints a clear pass/fail line; the
# script exits non-zero if any guard fails. Requires only bash + python3
# stdlib (tomllib) — no typst, no tytanic, no Docker.
#
#   (a) Determinism guard — no `datetime.today` in any test fixture (it
#       would flip the letter() date every day and flap visual refs).
#   (b) Profile-parity guard — every metadata.toml key path used by any
#       profile also exists in profile_en, the canonical/docs-driving
#       profile, modulo a small explicit allowlist of legitimate per-locale
#       keys (see ALLOWLIST below).
#   (d) Thumbnail guard — thumbnail.png is byte-identical to
#       docs/previews/cv-en.png, the render it is copied from.
#   (c) Starter-persona guard — every entry in the starter bibliography
#       lists John Doe as an author (see "Starter profile content is read
#       as facts" in AGENTS.md).

set -uo pipefail

# Resolve repo root (parent of this script's directory).
cd "$(dirname "$0")/.."

PASS=0
FAIL=0

pass() {
  printf '  \033[32m✓\033[0m %s\n' "$1"
  PASS=$((PASS + 1))
}

fail() {
  printf '  \033[31m✗\033[0m %s\n' "$1" >&2
  FAIL=$((FAIL + 1))
}

echo "Guard: determinism (no datetime.today in test fixtures)"

# --- (a) Determinism guard --------------------------------------------------
#
# letter()'s `date:` param defaults to datetime.today().display(). A
# fixture that forgets to override `date:` explicitly renders a different
# day every time it compiles, flapping pixel-perfect visual refs. Comments
# that merely *mention* datetime.today() (e.g. explaining why a fixture
# pins `date:`) are not violations — only code that would actually call it
# is. Line comments are stripped before searching so documentation doesn't
# false-positive.
determinism_violations=()
while IFS= read -r -d '' file; do
  if sed -E 's|//.*$||' "$file" | grep -q 'datetime\.today'; then
    determinism_violations+=("$file")
  fi
done < <(find tests -type f \( -name "test.typ" -o -name "fixture.typ" \) -print0 | sort -z)

if [[ ${#determinism_violations[@]} -eq 0 ]]; then
  pass "no datetime.today() usage in tests/**/test.typ or tests/**/fixture.typ"
else
  fail "datetime.today() found in fixture(s) — pass date: explicitly instead:"
  for f in "${determinism_violations[@]}"; do
    printf '       %s\n' "$f" >&2
  done
fi

echo
echo "Guard: profile parity (every profile's keys exist in profile_en)"

# --- (b) Profile-parity guard ------------------------------------------------
#
# profile_en is the canonical profile: docs/web/docs/configuration.md is
# generated from its comments (see AGENTS.md). If another profile's
# metadata.toml introduces a key path that profile_en doesn't have, the
# docs silently fall out of sync with what the package actually reads.
# This guard collects the full nested key-path set of every
# template/profile_*/metadata.toml and fails if any profile has a key path
# absent from profile_en — unless it's in the explicit allowlist below.
python3 - "$@" <<'PYEOF'
import sys
import tomllib
from pathlib import Path

# Legitimate per-locale keys that exist in a non-en profile but not in
# profile_en. Keep this list explicit and minimal — each entry should be
# re-justified whenever the guard flags something new.
ALLOWLIST = {
    # profile_zh sets an actual display_name (CJK first/last-name split
    # doesn't apply); profile_en only shows it as a commented-out example,
    # so it's not a real TOML key there.
    "personal.display_name",
    # profile_fr's [personal.info.custom-car] is a per-locale example of
    # the same "add your own custom icon" pattern profile_en demonstrates
    # under different example names (custom-degree, custom-cert). It's not
    # part of the schema, just an example key, so it need not exist in en.
    "personal.info.custom-car",
    "personal.info.custom-car.awesomeIcon",
    "personal.info.custom-car.text",
}


def keypaths(d, prefix=""):
    paths = set()
    for k, v in d.items():
        p = f"{prefix}.{k}" if prefix else k
        paths.add(p)
        if isinstance(v, dict):
            paths |= keypaths(v, p)
    return paths


root = Path(".")
profile_paths = sorted((root / "template").glob("profile_*/metadata.toml"))
if not profile_paths:
    print("  \033[31m✗\033[0m no template/profile_*/metadata.toml files found", file=sys.stderr)
    sys.exit(1)

profiles = {}
for p in profile_paths:
    name = p.parent.name
    with open(p, "rb") as f:
        data = tomllib.load(f)
    profiles[name] = keypaths(data)

if "profile_en" not in profiles:
    print("  \033[31m✗\033[0m profile_en/metadata.toml not found (canonical profile)", file=sys.stderr)
    sys.exit(1)

en_keys = profiles["profile_en"]
unexpected = {}
for name, keys in profiles.items():
    if name == "profile_en":
        continue
    missing = (keys - en_keys) - ALLOWLIST
    if missing:
        unexpected[name] = missing

used_allowlist = set()
for name, keys in profiles.items():
    if name == "profile_en":
        continue
    used_allowlist |= (keys - en_keys) & ALLOWLIST

stale_allowlist = ALLOWLIST - used_allowlist

if unexpected:
    print(
        "  \033[31m✗\033[0m key paths present in a profile but missing from profile_en:",
        file=sys.stderr,
    )
    for name in sorted(unexpected):
        for key in sorted(unexpected[name]):
            print(f"       {name}: {key}", file=sys.stderr)
    print(
        "     If this is a legitimate per-locale key, add it to ALLOWLIST in "
        "tests/guards.sh with a comment explaining why. Otherwise, add the "
        "key to template/profile_en/metadata.toml (the docs-driving profile).",
        file=sys.stderr,
    )
    sys.exit(1)

if stale_allowlist:
    print(
        "  \033[31m✗\033[0m ALLOWLIST entries no longer match any profile "
        "(remove the stale entries from tests/guards.sh):",
        file=sys.stderr,
    )
    for key in sorted(stale_allowlist):
        print(f"       {key}", file=sys.stderr)
    sys.exit(1)

print(
    f"  \033[32m✓\033[0m all key paths in {', '.join(n for n in sorted(profiles) if n != 'profile_en')} "
    "exist in profile_en (or are allowlisted)"
)
PYEOF
python_rc=$?

if [[ $python_rc -eq 0 ]]; then
  PASS=$((PASS + 1))
else
  FAIL=$((FAIL + 1))
fi

echo
echo "Guard: starter persona (John Doe co-authors every starter bib entry)"

# --- (c) Starter-persona guard ----------------------------------------------
#
# Users' agents read the starter as the candidate's real record. A sample
# publication the candidate did not write is a contradiction they flag or,
# worse, repeat. Every @entry in template/assets/publications.bib must list
# "Doe, John" in its author field.
bib_violations=$(python3 - <<'PYEOF'
import re
from pathlib import Path

text = Path("template/assets/publications.bib").read_text(encoding="utf-8")
for key, body in re.findall(r"@\w+\{([^,]+),(.*?)\n\}", text, flags=re.S):
    author = re.search(r"author\s*=\s*\{(.*?)\}", body)
    if not author or "Doe, John" not in author.group(1):
        print(key)
PYEOF
)

if [[ -z "$bib_violations" ]]; then
  pass "every entry in template/assets/publications.bib lists Doe, John"
else
  fail "starter bib entries without \"Doe, John\" as an author:"
  printf '       %s\n' $bib_violations >&2
fi

echo
echo "Guard: thumbnail (thumbnail.png matches docs/previews/cv-en.png)"

# --- (d) Thumbnail guard -----------------------------------------------------
#
# scripts/render_previews.sh copies the English preview to thumbnail.png (the
# Typst Universe thumbnail and the README hero image). A hand-edited or stale
# thumbnail breaks that link; regenerate with `just previews` or the "Update
# preview images" workflow.
if cmp -s thumbnail.png docs/previews/cv-en.png; then
  pass "thumbnail.png is identical to docs/previews/cv-en.png"
else
  fail "thumbnail.png differs from docs/previews/cv-en.png — run \`just previews\`"
fi

# Typst Universe requires a PNG thumbnail whose longer edge is at least
# 1080 px and whose size is at most 3 MiB (typst/packages docs/manifest.md).
thumbnail_check=$(python3 - <<'PYEOF'
import struct
from pathlib import Path

data = Path("thumbnail.png").read_bytes()
if data[:8] != b"\x89PNG\r\n\x1a\n":
    print("thumbnail.png is not a PNG")
else:
    width, height = struct.unpack(">II", data[16:24])
    if max(width, height) < 1080:
        print(f"longer edge is {max(width, height)} px (< 1080)")
    if len(data) > 3 * 1024 * 1024:
        print(f"size is {len(data)} bytes (> 3 MiB)")
PYEOF
)
if [[ -z "$thumbnail_check" ]]; then
  pass "thumbnail.png meets the Typst Universe size rules"
else
  fail "thumbnail.png breaks the Typst Universe rules: $thumbnail_check"
fi

echo
echo "Guards: $PASS passed, $FAIL failed"

if [[ $FAIL -gt 0 ]]; then
  exit 1
fi
