#!/usr/bin/env bash
#
# Extracted-text snapshots: what a plain-text PDF parser (ATS, LLM
# screener) reads from each regression fixture.
#
# For every fixture, compile the PDF and extract its text with
# `pdftotext -raw` (content-stream order, the order naive extractors use),
# then compare it with tests/text/snapshots/<fixture>.txt. With UPDATE=1 the
# snapshots are rewritten instead; `just test-update` does that. Review the
# snapshot diff like a ref PNG diff: it shows what machines now read.
# Runs in the test image (typst + pdftotext).

set -uo pipefail
cd "$(dirname "$0")/../.."

OUT=tests/text/.out
rm -rf "$OUT"
mkdir -p "$OUT"
trap 'rm -rf "$OUT"' EXIT

PASS=0
FAIL=0
FIXTURES=(cv-en cv-de cv-fr cv-it cv-zh letter-en letter-zh)

for name in "${FIXTURES[@]}"; do
  snapshot="tests/text/snapshots/$name.txt"
  if ! typst compile --root . "tests/regression/$name/test.typ" \
    "$OUT/$name.pdf" 2>"$OUT/$name.err"; then
    printf '  \033[31m✗\033[0m %-12s compile failed\n' "$name" >&2
    sed 's/^/       /' "$OUT/$name.err" >&2
    FAIL=$((FAIL + 1))
    continue
  fi
  # Normalize so the committed files survive the repo's pre-commit hooks
  # (end-of-file-fixer, trailing-whitespace): page breaks become a marker
  # line, trailing spaces go, and the file ends with exactly one newline.
  pdftotext -raw -enc UTF-8 "$OUT/$name.pdf" - |
    sed -e 's/\f/\n--- page break ---\n/g' -e 's/[[:space:]]*$//' |
    awk '{ line[NR] = $0 }
      END {
        n = NR
        while (n > 0 && (line[n] == "" || line[n] == "--- page break ---")) n--
        for (i = 1; i <= n; i++) print line[i]
      }' >"$OUT/$name.txt"

  if [[ "${UPDATE:-0}" == "1" ]]; then
    cp "$OUT/$name.txt" "$snapshot"
    printf '  \033[32m✓\033[0m %-12s snapshot updated\n' "$name"
    PASS=$((PASS + 1))
  elif [[ ! -f "$snapshot" ]]; then
    printf '  \033[31m✗\033[0m %-12s no snapshot (run just test-update)\n' "$name" >&2
    FAIL=$((FAIL + 1))
  elif diff -u "$snapshot" "$OUT/$name.txt" >"$OUT/$name.diff"; then
    printf '  \033[32m✓\033[0m %-12s\n' "$name"
    PASS=$((PASS + 1))
  else
    printf '  \033[31m✗\033[0m %-12s extracted text changed\n' "$name" >&2
    sed 's/^/       /' "$OUT/$name.diff" >&2
    FAIL=$((FAIL + 1))
  fi
done

echo
echo "Extracted-text snapshots: $PASS passed, $FAIL failed"
[[ $FAIL -eq 0 ]]
