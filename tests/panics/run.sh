#!/usr/bin/env bash
#
# Smoke tests for v3/v2 schema migration panics.
#
# Tytanic 0.2 reports any panicking test as failed (no expect-panic
# annotation), so panic assertions are exercised here as a small bash loop
# instead of via tytanic.
#
# Each fixture's first line is `// expected: <substring>`. The test passes
# when:
#   1. typst compile exits non-zero on the fixture, AND
#   2. stderr contains the expected substring.

set -uo pipefail

# Resolve repo root (parent of this script's grand-parent).
cd "$(dirname "$0")/../.."

PASS=0
FAIL=0
FAILED=()

# Use a tmp dir for the discarded PDFs.
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

for fixture in tests/panics/*/fixture.typ; do
  name=$(basename "$(dirname "$fixture")")
  expected=$(awk 'NR==1 && sub(/^\/\/ expected: /, "") { print; exit }' "$fixture")

  if [[ -z "$expected" ]]; then
    printf '  \033[31m✗\033[0m %-45s no `// expected: ...` header\n' "$name" >&2
    FAIL=$((FAIL + 1))
    FAILED+=("$name")
    continue
  fi

  err=$(typst compile --root . "$fixture" "$TMPDIR/out.pdf" 2>&1)
  rc=$?
  rm -f "$TMPDIR/out.pdf"

  if [[ $rc -eq 0 ]]; then
    printf '  \033[31m✗\033[0m %-45s expected non-zero exit, got 0\n' "$name" >&2
    FAIL=$((FAIL + 1))
    FAILED+=("$name")
  elif ! grep -qF -- "$expected" <<<"$err"; then
    printf '  \033[31m✗\033[0m %-45s expected substring not found\n' "$name" >&2
    printf '       expected: %s\n' "$expected" >&2
    printf '       got:      %s\n' "$(grep -m1 'error:' <<<"$err" | head -c 120)" >&2
    FAIL=$((FAIL + 1))
    FAILED+=("$name")
  else
    printf '  \033[32m✓\033[0m %s\n' "$name"
    PASS=$((PASS + 1))
  fi
done

echo
echo "Panic tests: $PASS passed, $FAIL failed"

if [[ $FAIL -gt 0 ]]; then
  exit 1
fi
