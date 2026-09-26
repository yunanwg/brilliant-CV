#!/usr/bin/env bash
#
# Experimental layout hooks (`--input brilliant-cv-query=1`).
#
# Tytanic cannot pass `--input`, so this script drives the CLI path that
# agents use: `typst eval 'query(<brilliant-cv>).map(it => it.value)'`. For each
# regression fixture it checks that
#   1. without the flag, the query returns no elements;
#   2. with the flag, tests/query/check.typ accepts the result: known kinds,
#      plain-text fields, pages in range, and one final `document` element
#      whose `pages` equals the real PDF page count.
# Needs only bash and typst, so it runs in the test image.

set -uo pipefail
cd "$(dirname "$0")/../.."

OUT=tests/query/.out
rm -rf "$OUT"
mkdir -p "$OUT"
trap 'rm -rf "$OUT"' EXIT

PASS=0
FAIL=0
QUERY="query(<brilliant-cv>).map(it => it.value)"
FIXTURES=(cv-en cv-de cv-fr cv-it cv-zh letter-en letter-zh)

for name in "${FIXTURES[@]}"; do
  fixture="tests/regression/$name/test.typ"

  # A failed query (e.g. a package download error) must not read as
  # "hooks emitted without the flag": report the command error instead.
  if ! off=$(typst eval --root . --in "$fixture" "$QUERY" 2>"$OUT/$name-off.err"); then
    printf '  \033[31m✗\033[0m %-12s query without the flag failed\n' "$name" >&2
    sed 's/^/       /' "$OUT/$name-off.err" >&2
    FAIL=$((FAIL + 1))
    continue
  fi
  if [[ "$off" != "[]" ]]; then
    printf '  \033[31m✗\033[0m %-12s hooks emitted without the flag\n' "$name" >&2
    FAIL=$((FAIL + 1))
    continue
  fi

  if ! typst eval --root . --input brilliant-cv-query=1 --in "$fixture" \
    "$QUERY" >"$OUT/$name.json" 2>"$OUT/$name.err"; then
    printf '  \033[31m✗\033[0m %-12s query failed\n' "$name" >&2
    sed 's/^/       /' "$OUT/$name.err" >&2
    FAIL=$((FAIL + 1))
    continue
  fi

  if ! typst compile --root . --input brilliant-cv-query=1 "$fixture" \
    "$OUT/$name-{p}.svg" 2>"$OUT/$name.err"; then
    printf '  \033[31m✗\033[0m %-12s compile failed\n' "$name" >&2
    sed 's/^/       /' "$OUT/$name.err" >&2
    FAIL=$((FAIL + 1))
    continue
  fi
  pages=$(find "$OUT" -name "$name-*.svg" | wc -l | tr -d ' ')

  if err=$(typst compile --root . --input "result=/$OUT/$name.json" \
    --input "pages=$pages" tests/query/check.typ "$OUT/check.pdf" 2>&1); then
    printf '  \033[32m✓\033[0m %-12s %s pages\n' "$name" "$pages"
    PASS=$((PASS + 1))
  else
    printf '  \033[31m✗\033[0m %-12s\n' "$name" >&2
    printf '%s\n' "$err" | sed 's/^/       /' >&2
    FAIL=$((FAIL + 1))
  fi
done

# The documented Typst 0.14 fallback (`typst query ... --field value`) must
# return the same elements as `typst eval`. Compare with whitespace removed.
fallback=$(typst query --root . --input brilliant-cv-query=1 \
  tests/regression/cv-en/test.typ '<brilliant-cv>' --field value 2>/dev/null | tr -d ' \n')
evaluated=$(tr -d ' \n' <"$OUT/cv-en.json")
if [[ -n "$fallback" && "$fallback" == "$evaluated" ]]; then
  printf '  \033[32m✓\033[0m %-12s typst query fallback matches typst eval\n' "cv-en"
  PASS=$((PASS + 1))
else
  printf '  \033[31m✗\033[0m %-12s typst query fallback differs from typst eval\n' "cv-en" >&2
  FAIL=$((FAIL + 1))
fi

echo
echo "Query hook tests: $PASS passed, $FAIL failed"
[[ $FAIL -eq 0 ]]
