#!/usr/bin/env python3
"""Fail-closed package and release checks shared by local work and CI."""

from __future__ import annotations

import argparse
import filecmp
import os
import re
import shutil
import subprocess
import sys
import tempfile
import tomllib
from pathlib import Path, PurePosixPath


ROOT = Path(__file__).resolve().parent.parent
MANIFEST = ROOT / "typst.toml"
SEMVER = re.compile(r"^[0-9]+\.[0-9]+\.[0-9]+$")
IMPORT = re.compile(r"@preview/brilliant-cv:([0-9]+\.[0-9]+\.[0-9]+)")
CURRENT_VERSION_SOURCES = (
    ROOT / ".github/ISSUE_TEMPLATE/bug_report.yml",
    ROOT / "docs/web/generate-api-reference.py",
    ROOT / "docs/web/docs/getting-started.md",
    ROOT / "docs/web/docs/components.md",
    ROOT / "docs/web/docs/recipes.md",
    ROOT / "docs/web/docs/troubleshooting.md",
)
MIGRATION_GUIDE = ROOT / "docs/web/docs/migration.md"
MIGRATION_CURRENT_MARKER = "// release-current-version"
# Markdown `[text](target)` / `![alt](target)` and HTML `src=` / `href=` targets.
README_LINK = re.compile(r"\]\(\s*<?([^)\s>]+)|\b(?:src|href)=[\"']([^\"']+)")


class ContractError(RuntimeError):
    """A release invariant was not satisfied."""


def run(
    command: list[str],
    *,
    cwd: Path = ROOT,
    capture: bool = False,
) -> subprocess.CompletedProcess[str]:
    print("+ " + " ".join(command), flush=True)
    return subprocess.run(
        command,
        cwd=cwd,
        check=True,
        text=True,
        capture_output=capture,
    )


def manifest() -> dict[str, object]:
    with MANIFEST.open("rb") as stream:
        return tomllib.load(stream)


def package_config() -> dict[str, object]:
    value = manifest().get("package")
    if not isinstance(value, dict):
        raise ContractError("typst.toml is missing [package]")
    return value


def payload_package_config(package_dir: Path) -> dict[str, object]:
    payload_manifest = package_dir / "typst.toml"
    if not payload_manifest.is_file():
        raise ContractError(f"not a package payload: {package_dir}")
    with payload_manifest.open("rb") as stream:
        value = tomllib.load(stream).get("package")
    if not isinstance(value, dict):
        raise ContractError(f"{payload_manifest} is missing [package]")
    return value


def package_version() -> str:
    value = package_config().get("version")
    if not isinstance(value, str) or not SEMVER.fullmatch(value):
        raise ContractError(f"invalid [package].version: {value!r}")
    return value


def current_reference_files() -> list[Path]:
    files = sorted((ROOT / "template").glob("**/*.typ"))
    files.extend(path for path in CURRENT_VERSION_SOURCES if path.exists())
    return files


def referenced_versions(path: Path) -> set[str]:
    return set(IMPORT.findall(path.read_text(encoding="utf-8")))


def migration_current_version() -> str:
    text = MIGRATION_GUIDE.read_text(encoding="utf-8")
    if text.count(MIGRATION_CURRENT_MARKER) != 1:
        raise ContractError(
            f"{MIGRATION_GUIDE.relative_to(ROOT)} must contain exactly one "
            f"{MIGRATION_CURRENT_MARKER!r} marker"
        )
    after_marker = text.split(MIGRATION_CURRENT_MARKER, 1)[1]
    match = IMPORT.search(after_marker)
    if match is None:
        raise ContractError("release-current-version marker is not followed by an import")
    return match.group(1)


def check_version() -> None:
    expected = package_version()
    errors: list[str] = []
    references = 0
    for path in current_reference_files():
        text = path.read_text(encoding="utf-8")
        versions = set(IMPORT.findall(text))
        references += len(IMPORT.findall(text))
        unexpected = sorted(versions - {expected})
        if unexpected:
            errors.append(
                f"{path.relative_to(ROOT)} uses {', '.join(unexpected)}; "
                f"expected {expected}"
            )

    try:
        migration_version = migration_current_version()
        references += 1
        if migration_version != expected:
            errors.append(
                f"{MIGRATION_GUIDE.relative_to(ROOT)} current v4 example uses "
                f"{migration_version}; expected {expected}"
            )
    except ContractError as error:
        errors.append(str(error))

    if references == 0:
        errors.append("no current-version package imports were found")
    if errors:
        raise ContractError("version contract failed:\n  " + "\n  ".join(errors))
    print(f"Version contract passed: {expected} ({references} current references)")


def replace_exact(path: Path, old: str, new: str) -> int:
    text = path.read_text(encoding="utf-8")
    before = len(re.findall(rf"@preview/brilliant-cv:{re.escape(old)}\b", text))
    updated = re.sub(
        rf"@preview/brilliant-cv:{re.escape(old)}\b",
        f"@preview/brilliant-cv:{new}",
        text,
    )
    if updated != text:
        path.write_text(updated, encoding="utf-8")
    return before


def replace_migration_current(old: str, new: str) -> int:
    text = MIGRATION_GUIDE.read_text(encoding="utf-8")
    if migration_current_version() != old:
        raise ContractError("migration guide current-version example is inconsistent")
    prefix, suffix = text.split(MIGRATION_CURRENT_MARKER, 1)
    match = IMPORT.search(suffix)
    assert match is not None
    suffix = suffix[: match.start(1)] + new + suffix[match.end(1) :]
    MIGRATION_GUIDE.write_text(prefix + MIGRATION_CURRENT_MARKER + suffix)
    return 1


def check_prepare_state(new: str) -> None:
    status = run(
        ["git", "status", "--porcelain", "--untracked-files=all"], capture=True
    ).stdout
    if status:
        raise ContractError(
            "release preparation requires a fully clean working tree, "
            "including untracked files"
        )

    head = run(["git", "rev-parse", "HEAD"], capture=True).stdout.strip()
    try:
        main = run(["git", "rev-parse", "origin/main"], capture=True).stdout.strip()
    except subprocess.CalledProcessError as error:
        raise ContractError("origin/main is unavailable; fetch it first") from error
    if head != main:
        raise ContractError(
            f"HEAD {head} does not equal local origin/main {main}; synchronize first"
        )
    if run(["git", "tag", "--list", f"v{new}"], capture=True).stdout.strip():
        raise ContractError(f"tag v{new} already exists locally")


def bump_version(new: str) -> None:
    if not SEMVER.fullmatch(new):
        raise ContractError(f"invalid version {new!r}; expected X.Y.Z")
    old = package_version()
    if old == new:
        raise ContractError(f"typst.toml already declares {new}")
    check_prepare_state(new)
    check_version()

    text = MANIFEST.read_text(encoding="utf-8")
    updated, count = re.subn(
        rf'(?m)^version = "{re.escape(old)}"$', f'version = "{new}"', text, count=1
    )
    if count != 1:
        raise ContractError("could not update exactly one manifest version")
    MANIFEST.write_text(updated, encoding="utf-8")

    replacements = sum(
        replace_exact(path, old, new) for path in current_reference_files()
    )
    replacements += replace_migration_current(old, new)
    if replacements == 0:
        raise ContractError("no current package imports were updated")
    check_version()
    print(
        f"Prepared version {new}: updated {replacements} current references; "
        "historical migration imports were preserved."
    )


def git_files() -> list[Path]:
    # A release payload is a projection of the immutable commit, never of
    # untracked workstation or runner state.
    result = run(["git", "ls-files", "--cached", "-z"], capture=True)
    paths: list[Path] = []
    for item in result.stdout.split("\0"):
        if item:
            path = ROOT / item
            if path.is_file() or path.is_symlink():
                paths.append(path)
    return paths


def normalized_excludes() -> tuple[str, ...]:
    """Return the `[package].exclude` globs, validated.

    Typst Universe's bundler applies these with gitignore semantics: a
    pattern without a slash matches at any depth, a leading `/` anchors it
    to the package root, and a trailing `/` matches directories only.
    """
    raw = package_config().get("exclude", [])
    if not isinstance(raw, list) or not all(isinstance(item, str) for item in raw):
        raise ContractError("[package].exclude must be an array of globs")
    result: list[str] = []
    for item in raw:
        body = item.strip("/")
        if not body or body == "." or ".." in PurePosixPath(body).parts:
            raise ContractError(f"unsafe package exclude glob: {item!r}")
        if item.startswith("!"):
            raise ContractError(
                f"negated exclude glob is not modeled by the release contract: {item!r}"
            )
        result.append(item)
    return tuple(result)


def _glob_regex(glob: str) -> re.Pattern[str]:
    """Translate a gitignore glob body: `*` and `?` stay within one path
    segment, `**` spans segments."""
    out = ""
    i = 0
    while i < len(glob):
        char = glob[i]
        if glob.startswith("**", i):
            out += ".*"
            i += 2
            if glob.startswith("/", i):
                i += 1
                out += "(?:/)?"
            continue
        if char == "*":
            out += "[^/]*"
        elif char == "?":
            out += "[^/]"
        elif char == "[":
            end = glob.find("]", i + 1)
            if end == -1:
                out += re.escape(char)
            else:
                out += "[" + glob[i + 1 : end].replace("!", "^", 1) + "]"
                i = end
        else:
            out += re.escape(char)
        i += 1
    return re.compile(out)


def _glob_matches(pattern: str, relative: PurePosixPath, is_dir: bool) -> bool:
    if pattern.endswith("/") and not is_dir:
        return False
    body = pattern.rstrip("/")
    anchored = body.startswith("/") or "/" in body
    body = body.lstrip("/")
    target = relative.as_posix() if anchored else relative.name
    return _glob_regex(body).fullmatch(target) is not None


def is_excluded(relative: PurePosixPath, excludes: tuple[str, ...]) -> bool:
    """True when a file, or any directory above it, matches an exclude glob."""
    candidates = [(relative, False)] + [
        (parent, True) for parent in relative.parents if str(parent) != "."
    ]
    return any(
        _glob_matches(pattern, path, is_dir)
        for pattern in excludes
        for path, is_dir in candidates
    )


def excluded_files(package_dir: Path, excludes: tuple[str, ...]) -> list[str]:
    """Files under package_dir that the exclude globs would drop."""
    leaked: list[str] = []
    for path in package_dir.rglob("*"):
        if path.is_file():
            relative = PurePosixPath(path.relative_to(package_dir).as_posix())
            if is_excluded(relative, excludes):
                leaked.append(relative.as_posix())
    return sorted(leaked)


def required_payload_paths() -> tuple[PurePosixPath, ...]:
    return tuple(
        PurePosixPath(path)
        for path in (
            "typst.toml",
            "src/lib.typ",
            "template/cv.typ",
            "template/letter.typ",
            "template/AGENTS.md",
            "template/metadata.toml.schema.json",
            "thumbnail.png",
            "README.md",
            "LICENSE",
        )
    )


def assemble(output: Path) -> None:
    output = output.resolve()
    if output.exists():
        raise ContractError(f"package output already exists: {output}")
    if output == ROOT or ROOT in output.parents:
        raise ContractError("package output must be outside the repository")

    check_version()
    excludes = normalized_excludes()
    output.mkdir(parents=True)
    copied: list[PurePosixPath] = []
    for source in git_files():
        relative = PurePosixPath(source.relative_to(ROOT).as_posix())
        if is_excluded(relative, excludes):
            continue
        destination = output / Path(relative)
        destination.parent.mkdir(parents=True, exist_ok=True)
        if source.is_symlink():
            destination.symlink_to(os.readlink(source))
        else:
            shutil.copy2(source, destination)
        copied.append(relative)

    missing = [
        str(path) for path in required_payload_paths() if not (output / Path(path)).is_file()
    ]
    if missing:
        raise ContractError("package payload is missing: " + ", ".join(missing))
    print(f"Assembled {len(copied)} files at {output}")


def check_readme_links(package_dir: Path) -> None:
    # Typst Universe rejects README links to files the package does not ship,
    # which is easy to miss when a linked file sits under `exclude`.
    readme = package_dir / "README.md"
    broken: list[str] = []
    for match in README_LINK.finditer(readme.read_text(encoding="utf-8")):
        target = match.group(1) or match.group(2)
        if re.match(r"^[a-z][a-z0-9+.-]*:", target, re.IGNORECASE) or target.startswith(
            ("#", "//")
        ):
            continue
        path = target.split("#", 1)[0].split("?", 1)[0].lstrip("/")
        if path and not (package_dir / path).exists():
            broken.append(target)
    if broken:
        raise ContractError(
            "README.md links to files missing from the payload: " + ", ".join(broken)
        )


def check_payload(package_dir: Path) -> None:
    package_dir = package_dir.resolve()
    config = payload_package_config(package_dir)
    name = config.get("name")
    version = config.get("version")
    if name != package_config().get("name") or version != package_version():
        raise ContractError(
            f"payload declares {name}:{version}; repository declares "
            f"{package_config().get('name')}:{package_version()}"
        )

    missing = [
        str(path)
        for path in required_payload_paths()
        if not (package_dir / Path(path)).is_file()
    ]
    if missing:
        raise ContractError("payload is missing: " + ", ".join(missing))
    leaked = excluded_files(package_dir, normalized_excludes())
    if leaked:
        raise ContractError("payload contains excluded paths: " + ", ".join(leaked))
    check_readme_links(package_dir)
    print(f"Package payload contract passed: {name}:{version}")


def typst_version() -> str:
    return run(["typst", "--version"], capture=True).stdout.strip()


def smoke(package_dir: Path) -> None:
    package_dir = package_dir.resolve()
    check_payload(package_dir)
    config = payload_package_config(package_dir)
    name = config["name"]
    version = config["version"]

    with tempfile.TemporaryDirectory(prefix="brilliant-cv-smoke-") as directory:
        temporary = Path(directory)
        package_root = temporary / "packages"
        local_package = package_root / "preview" / str(name) / str(version)
        shutil.copytree(package_dir, local_package, symlinks=True)
        project = temporary / "initialized-project"
        run(
            [
                "typst",
                "init",
                "--package-path",
                str(package_root),
                f"@preview/{name}:{version}",
                str(project),
            ]
        )

        for entrypoint in ("cv.typ", "letter.typ"):
            if not (project / entrypoint).is_file():
                raise ContractError(f"fresh init did not create {entrypoint}")
            for profile in ("en", "de", "fr", "it", "zh"):
                output = temporary / f"{entrypoint.removesuffix('.typ')}-{profile}.pdf"
                run(
                    [
                        "typst",
                        "compile",
                        "--package-path",
                        str(package_root),
                        "--root",
                        str(project),
                        "--input",
                        f"profile={profile}",
                        str(project / entrypoint),
                        str(output),
                    ]
                )

        # template/AGENTS.md documents a per-application subfolder that reads
        # ../../profile_<name>/ and compiles with `--root .`; keep that
        # documented workflow working.
        if not (project / "AGENTS.md").is_file():
            raise ContractError("fresh init did not create AGENTS.md")
        application = project / "applications" / "smoke"
        application.mkdir(parents=True)
        source = (project / "cv.typ").read_text(encoding="utf-8")
        nested = source.replace('"profile_"', '"../../profile_"').replace(
            'image("assets/', 'image("../../assets/'
        )
        if nested == source:
            raise ContractError("starter cv.typ no longer uses profile_ paths")
        (application / "cv.typ").write_text(nested, encoding="utf-8")
        run(
            [
                "typst",
                "compile",
                "--package-path",
                str(package_root),
                "--root",
                str(project),
                str(application / "cv.typ"),
                str(temporary / "application-cv.pdf"),
            ]
        )
    print(
        "Fresh-init smoke passed: CV + letter, 5 profiles, AGENTS.md subfolder "
        f"workflow, {typst_version()}"
    )


def check_release_ref(tag: str) -> None:
    expected_tag = f"v{package_version()}"
    if tag != expected_tag:
        raise ContractError(f"tag {tag!r} does not match manifest {expected_tag!r}")
    check_version()
    if run(["git", "status", "--porcelain"], capture=True).stdout:
        raise ContractError("release checkout is not clean")

    head = run(["git", "rev-parse", "HEAD"], capture=True).stdout.strip()
    tag_commit = run(
        ["git", "rev-parse", f"refs/tags/{tag}^{{commit}}"], capture=True
    ).stdout.strip()
    if head != tag_commit:
        raise ContractError(f"checkout {head} is not tag commit {tag_commit}")
    try:
        run(["git", "merge-base", "--is-ancestor", head, "origin/main"])
    except subprocess.CalledProcessError as error:
        raise ContractError(f"tag commit {head} is not on origin/main") from error
    print(f"Release ref contract passed: {tag} -> {head}")


def compare_generated_docs() -> None:
    target = ROOT / "docs/web/docs/api-reference.md"
    with tempfile.TemporaryDirectory(prefix="brilliant-cv-docs-") as directory:
        copy = Path(directory) / "repo"
        shutil.copytree(
            ROOT,
            copy,
            symlinks=True,
            ignore=shutil.ignore_patterns(".git", "site", "temp", "__pycache__"),
        )
        run([sys.executable, "docs/web/generate-api-reference.py"], cwd=copy)
        generated = copy / "docs/web/docs/api-reference.md"
        if not filecmp.cmp(target, generated, shallow=False):
            raise ContractError(
                "docs/web/docs/api-reference.md is stale; run `just docs-generate`"
            )
    print("Generated API reference is current")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest="command", required=True)
    commands.add_parser("check-version")
    bump = commands.add_parser("bump")
    bump.add_argument("version")
    assemble_parser = commands.add_parser("assemble")
    assemble_parser.add_argument("output", type=Path)
    smoke_parser = commands.add_parser("smoke")
    smoke_parser.add_argument("package_dir", type=Path)
    payload = commands.add_parser("check-payload")
    payload.add_argument("package_dir", type=Path)
    release_ref = commands.add_parser("check-release-ref")
    release_ref.add_argument("tag")
    commands.add_parser("check-generated-docs")
    args = parser.parse_args()

    try:
        if args.command == "check-version":
            check_version()
        elif args.command == "bump":
            bump_version(args.version)
        elif args.command == "assemble":
            assemble(args.output)
        elif args.command == "smoke":
            smoke(args.package_dir)
        elif args.command == "check-payload":
            check_payload(args.package_dir)
        elif args.command == "check-release-ref":
            check_release_ref(args.tag)
        elif args.command == "check-generated-docs":
            compare_generated_docs()
    except (ContractError, OSError, subprocess.CalledProcessError) as error:
        print(f"ERROR: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
