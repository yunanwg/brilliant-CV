#!/usr/bin/env bash
#
# The starter must stay accessible: compile every profile's CV and cover
# letter from template/ as PDF/UA-1, which fails on, e.g., an image without
# alt text or a glyph no font can display. Runs in the test image, which has
# the fonts the starter needs (Font Awesome included); without them the icon
# glyphs alone would fail PDF/UA-1.

set -uo pipefail
cd "$(dirname "$0")/../.."

OUT=$(mktemp -d)
trap 'rm -rf "$OUT"' EXIT

PASS=0
FAIL=0

for entrypoint in cv letter; do
  for profile in en de fr it zh; do
    if err=$(typst compile --root template --input "profile=$profile" \
      --pdf-standard ua-1 "template/$entrypoint.typ" \
      "$OUT/$entrypoint-$profile.pdf" 2>&1); then
      printf '  \033[32m✓\033[0m %-10s %s\n' "$entrypoint" "$profile"
      PASS=$((PASS + 1))
    else
      printf '  \033[31m✗\033[0m %-10s %s\n' "$entrypoint" "$profile" >&2
      printf '%s\n' "$err" | grep -E '^error' | sort | uniq -c | sed 's/^/       /' >&2
      FAIL=$((FAIL + 1))
    fi
  done
done

echo
echo "PDF/UA-1 starter checks: $PASS passed, $FAIL failed"
[[ $FAIL -eq 0 ]]
