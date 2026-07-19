#!/usr/bin/env python3
"""Regression test for safe, targeted release version bumps."""

from __future__ import annotations

import shutil
import subprocess
import sys
import tempfile
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent


def run(command: list[str], cwd: Path) -> subprocess.CompletedProcess[str]:
    return subprocess.run(command, cwd=cwd, check=True, text=True, capture_output=True)


def write(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding="utf-8")


def main() -> int:
    with tempfile.TemporaryDirectory(prefix="release-contract-test-") as directory:
        fixture = Path(directory) / "repo"
        fixture.mkdir()
        write(
            fixture / "typst.toml",
            '[package]\nname = "brilliant-cv"\nversion = "4.0.1"\nexclude = []\n',
        )
        write(
            fixture / "template/cv.typ",
            '#import "@preview/brilliant-cv:4.0.1": cv\n',
        )
        for relative in (
            "docs/web/generate-api-reference.py",
            "docs/web/docs/getting-started.md",
            "docs/web/docs/components.md",
            "docs/web/docs/recipes.md",
            "docs/web/docs/troubleshooting.md",
        ):
            write(fixture / relative, '#import "@preview/brilliant-cv:4.0.1": cv\n')
        write(
            fixture / "docs/web/docs/migration.md",
            """\
```typ
#import "@preview/brilliant-cv:3.3.0": cv
```

// release-current-version

```typ
#import "@preview/brilliant-cv:4.0.1": cv
```

```typ
#import "@preview/brilliant-cv:2.0.8": *
```
""",
        )
        (fixture / "scripts").mkdir()
        shutil.copy2(ROOT / "scripts/release_contract.py", fixture / "scripts")

        run(["git", "init", "--quiet"], fixture)
        run(["git", "config", "user.name", "release-contract-test"], fixture)
        run(["git", "config", "user.email", "test@example.invalid"], fixture)
        run(["git", "config", "commit.gpgsign", "false"], fixture)
        run(["git", "add", "."], fixture)
        run(["git", "commit", "--quiet", "-m", "fixture"], fixture)
        run(["git", "update-ref", "refs/remotes/origin/main", "HEAD"], fixture)

        dirty_file = fixture / "untracked-work.txt"
        write(dirty_file, "do not overwrite contributor work\n")
        dirty_result = subprocess.run(
            [sys.executable, "scripts/release_contract.py", "bump", "4.0.2"],
            cwd=fixture,
            check=False,
            text=True,
            capture_output=True,
        )
        assert dirty_result.returncode != 0
        assert "fully clean working tree" in dirty_result.stderr
        assert 'version = "4.0.1"' in (fixture / "typst.toml").read_text()
        dirty_file.unlink()

        result = run(
            [sys.executable, "scripts/release_contract.py", "bump", "4.0.2"], fixture
        )
        assert "Version contract passed: 4.0.2" in result.stdout
        assert 'version = "4.0.2"' in (fixture / "typst.toml").read_text()
        assert "brilliant-cv:4.0.2" in (fixture / "template/cv.typ").read_text()

        migration = (fixture / "docs/web/docs/migration.md").read_text()
        assert migration.count("brilliant-cv:4.0.2") == 1
        assert migration.count("brilliant-cv:4.0.1") == 0
        assert migration.count("brilliant-cv:3.3.0") == 1
        assert migration.count("brilliant-cv:2.0.8") == 1

        run(["git", "add", "."], fixture)
        run(["git", "commit", "--quiet", "-m", "prepare 4.0.2"], fixture)
        run(["git", "update-ref", "refs/remotes/origin/main", "HEAD"], fixture)
        run(["git", "tag", "v4.0.2"], fixture)
        release_ref = run(
            [
                sys.executable,
                "scripts/release_contract.py",
                "check-release-ref",
                "v4.0.2",
            ],
            fixture,
        )
        assert "Release ref contract passed" in release_ref.stdout

    print("release-contract bump regression passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
