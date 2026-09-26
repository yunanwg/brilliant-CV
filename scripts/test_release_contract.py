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
            ".github/ISSUE_TEMPLATE/bug_report.yml",
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
        assert "brilliant-cv:4.0.2" in (
            fixture / ".github/ISSUE_TEMPLATE/bug_report.yml"
        ).read_text()

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

    sys.dont_write_bytecode = True
    sys.path.insert(0, str(ROOT / "scripts"))
    import release_contract

    with tempfile.TemporaryDirectory(prefix="readme-links-test-") as directory:
        package = Path(directory)
        write(package / "LICENSE", "license\n")
        write(
            package / "README.md",
            '<img src="LICENSE"> [ok](LICENSE#top) [web](https://example.com)\n'
            "[anchor](#usage) [missing](CONTRIBUTING.md)\n",
        )
        try:
            release_contract.check_readme_links(package)
        except release_contract.ContractError as error:
            assert "CONTRIBUTING.md" in str(error)
            assert "LICENSE" not in str(error)
        else:
            raise AssertionError("README link to an excluded file was not rejected")

        write(package / "README.md", "[ok](LICENSE) [web](https://example.com)\n")
        release_contract.check_readme_links(package)

    # `[package].exclude` follows Typst Universe's bundler: gitignore
    # semantics. An unanchored name matches at any depth, which would drop a
    # starter file (e.g. template/AGENTS.md) that shares a name with a
    # repository-only file.
    from pathlib import PurePosixPath

    def excluded(pattern: str, path: str) -> bool:
        return release_contract.is_excluded(PurePosixPath(path), (pattern,))

    assert excluded("/AGENTS.md", "AGENTS.md")
    assert not excluded("/AGENTS.md", "template/AGENTS.md")
    assert excluded("AGENTS.md", "template/AGENTS.md")
    assert excluded("/docs", "docs/web/docs/index.md")
    assert not excluded("/docs", "template/docs/notes.md")
    assert excluded("docs/web", "docs/web/generate-api-reference.py")
    assert not excluded("docs/web", "template/docs/web/x.typ")
    assert excluded("*.pdf", "template/out/cv.pdf")
    assert excluded("out/", "template/out/cv.pdf")
    assert not excluded("out/", "template/out")
    # `*` stays within one path segment; `**` spans segments.
    assert excluded("/docs/*.md", "docs/index.md")
    assert not excluded("/docs/*.md", "docs/web/docs/index.md")
    assert excluded("/docs/**/*.md", "docs/web/docs/index.md")

    with tempfile.TemporaryDirectory(prefix="payload-leak-test-") as directory:
        package = Path(directory)
        write(package / "AGENTS.md", "repo-only\n")
        write(package / "template/AGENTS.md", "starter\n")
        assert release_contract.excluded_files(package, ("/AGENTS.md",)) == ["AGENTS.md"]
        assert release_contract.excluded_files(package, ("AGENTS.md",)) == [
            "AGENTS.md",
            "template/AGENTS.md",
        ]

    original_config = release_contract.package_config
    release_contract.package_config = lambda: {"exclude": ["!template/keep.md"]}
    try:
        release_contract.normalized_excludes()
    except release_contract.ContractError as error:
        assert "negated" in str(error)
    else:
        raise AssertionError("negated exclude glob was not rejected")
    finally:
        release_contract.package_config = original_config

    print("release-contract bump regression passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
