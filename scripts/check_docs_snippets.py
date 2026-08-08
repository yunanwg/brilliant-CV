#!/usr/bin/env python3
"""Compile every generated Typst API example against the local package."""

from __future__ import annotations

import re
import subprocess
import tempfile
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent
API_REFERENCE = ROOT / "docs" / "web" / "docs" / "api-reference.md"
TYPST_BLOCK = re.compile(r"```typ\n(.*?)\n```", re.DOTALL)
PACKAGE_IMPORT = re.compile(
    r'^#import\s+"@preview/brilliant-cv:[^"]+"[^\n]*\n?', re.MULTILINE
)

PREAMBLE = """\
#import "/src/lib.typ": *
#import "/tests/common.typ": minimal-metadata
#let _metadata = minimal-metadata
#show: cv.with(minimal-metadata, header-info: none)

"""


def main() -> int:
    snippets = TYPST_BLOCK.findall(API_REFERENCE.read_text())
    if not snippets:
        raise SystemExit(f"no Typst snippets found in {API_REFERENCE}")

    failures: list[tuple[int, str]] = []
    with tempfile.TemporaryDirectory(prefix=".docs-snippets-", dir=ROOT) as tmp:
        tmpdir = Path(tmp)
        for index, snippet in enumerate(snippets, start=1):
            source = tmpdir / f"api-{index}.typ"
            output = tmpdir / f"api-{index}.pdf"
            source.write_text(PREAMBLE + PACKAGE_IMPORT.sub("", snippet) + "\n")
            result = subprocess.run(
                [
                    "typst",
                    "compile",
                    "--root",
                    str(ROOT),
                    str(source),
                    str(output),
                ],
                cwd=ROOT,
                capture_output=True,
                text=True,
                check=False,
            )
            if result.returncode != 0:
                failures.append((index, result.stderr.strip()))

    if failures:
        for index, error in failures:
            print(f"API snippet {index} failed:\n{error}")
        return 1

    print(f"compiled {len(snippets)} generated API snippets")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
