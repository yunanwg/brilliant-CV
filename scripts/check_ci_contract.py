#!/usr/bin/env python3
"""Guard immutable CI inputs and narrow automation boundaries."""

from __future__ import annotations

import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent
ACTION = re.compile(r"^\s*(?:-\s+)?uses:\s+([^#\s]+)", re.MULTILINE)
SHA = re.compile(r"^[0-9a-f]{40}$")
UPSTREAM_PR_BODY = ".github/typst-packages-pr-body.md"
UPSTREAM_PR_BODY_REQUIRED = (
    "I am submitting",
    "- [ ] a new package",
    "- [x] an update for a package",
    "Description:",
    "{{VERSION}}",
    "I have read and followed the submission guidelines",
    "selected [a name](",
    "Explanation:",
    "[`typst.toml`](",
    "[`README.md`](",
    "have chosen [a license](",
    "tested my package locally on my system and it worked",
    "[`exclude`d](",
    "template directory without restriction",
)


def action_errors(path: Path, text: str) -> list[str]:
    errors: list[str] = []
    for value in ACTION.findall(text):
        if value.startswith("./"):
            continue
        if "@" not in value:
            errors.append(f"{path}: action has no ref: {value}")
            continue
        _, ref = value.rsplit("@", 1)
        if not SHA.fullmatch(ref):
            errors.append(f"{path}: action ref is mutable: {value}")
    return errors


def docker_errors(text: str) -> list[str]:
    errors: list[str] = []
    first = next((line for line in text.splitlines() if line.startswith("FROM ")), "")
    if not re.search(r"@sha256:[0-9a-f]{64}$", first):
        errors.append("tests/Dockerfile: base image is not pinned by digest")
    downloads = text.count("https://github.com/")
    checksums = text.count("sha256sum -c -")
    if downloads == 0 or downloads != checksums:
        errors.append(
            "tests/Dockerfile: each GitHub download must have one SHA-256 check "
            f"({downloads} downloads, {checksums} checks)"
        )
    return errors


def release_remote_errors(text: str) -> list[str]:
    """Reject fork-clone remote setup that is not safe to repeat."""
    if "gh repo clone" not in text or "git remote add upstream" not in text:
        return []
    if (
        "git remote get-url upstream" in text
        and "git remote set-url upstream" in text
    ):
        return []
    return [
        "release workflow must handle the upstream remote that gh repo clone "
        "may create for forks"
    ]


def upstream_pr_body_errors(template: str | None, release: str) -> list[str]:
    """Keep automated Universe submissions aligned with the upstream template."""
    errors: list[str] = []
    if template is None:
        errors.append(f"missing Typst Packages PR body template: {UPSTREAM_PR_BODY}")
    else:
        for required in UPSTREAM_PR_BODY_REQUIRED:
            if required not in template:
                errors.append(
                    f"{UPSTREAM_PR_BODY}: missing required submission text: {required}"
                )

    if UPSTREAM_PR_BODY not in release or "--body-file" not in release:
        errors.append("release workflow must create the upstream PR from its body file")
    if 'gh pr edit "$OPEN_PR" --body-file "$PR_BODY"' not in release:
        errors.append("release workflow must refresh the body of a reused upstream PR")
    if re.search(r"^\s*--body\s+", release, re.MULTILINE):
        errors.append("release workflow must not replace the upstream template inline")
    return errors


def policy_errors(root: Path) -> list[str]:
    errors: list[str] = []
    for path in sorted((root / ".github/workflows").glob("*.yaml")):
        errors.extend(action_errors(path.relative_to(root), path.read_text()))

    errors.extend(docker_errors((root / "tests/Dockerfile").read_text()))

    release = (root / ".github/workflows/release-and-publish.yaml").read_text()
    errors.extend(release_remote_errors(release))
    upstream_pr_body_path = root / UPSTREAM_PR_BODY
    upstream_pr_body = (
        upstream_pr_body_path.read_text() if upstream_pr_body_path.is_file() else None
    )
    errors.extend(upstream_pr_body_errors(upstream_pr_body, release))
    for forbidden in ("workflow_dispatch", "git reset --hard", "git push origin main --force"):
        if forbidden in release:
            errors.append(f"release workflow contains forbidden operation: {forbidden}")

    sponsors = (root / ".github/workflows/sponsors.yaml").read_text()
    if "workflow_dispatch:" not in sponsors:
        errors.append("sponsor refresh must remain manually dispatchable")
    if "schedule:" in sponsors:
        errors.append("sponsor refresh must remain manual-only")

    precommit = (root / ".pre-commit-config.yaml").read_text()
    if "delete-all-pdfs" in precommit or 'find . -type f -name "*.pdf" -delete' in precommit:
        errors.append("pre-commit must reject PDFs, not delete workspace files")

    justfile = (root / "justfile").read_text()
    if 'find . -name "*.pdf"' in justfile:
        errors.append("just clean must not search and delete PDFs across the repository")

    for relative in (
        "docs/web/requirements.txt",
        "docs/web/requirements.lock",
        "scripts/requirements-checks.txt",
        "scripts/requirements-checks.lock",
    ):
        if not (root / relative).is_file():
            errors.append(f"missing dependency contract: {relative}")
    return errors


def self_test() -> None:
    assert not action_errors(Path("ok.yaml"), "uses: owner/action@" + "a" * 40)
    assert action_errors(Path("bad.yaml"), "uses: owner/action@v7")
    assert docker_errors("FROM ubuntu:24.04\nRUN curl https://github.com/x\n")
    unsafe_remote = """\
gh repo clone owner/fork universe
git remote add upstream https://github.com/upstream/repo.git
"""
    safe_remote = """\
gh repo clone owner/fork universe
if git remote get-url upstream >/dev/null 2>&1; then
  git remote set-url upstream https://github.com/upstream/repo.git
else
  git remote add upstream https://github.com/upstream/repo.git
fi
"""
    assert release_remote_errors(unsafe_remote)
    assert not release_remote_errors(safe_remote)
    valid_pr_body = "\n".join(UPSTREAM_PR_BODY_REQUIRED)
    valid_release = (
        f"render {UPSTREAM_PR_BODY}\n"
        'gh pr edit "$OPEN_PR" --body-file "$PR_BODY"\n'
        "gh pr create --body-file body.md"
    )
    assert not upstream_pr_body_errors(valid_pr_body, valid_release)
    assert upstream_pr_body_errors(None, valid_release)
    assert upstream_pr_body_errors(valid_pr_body, 'gh pr create --body "short"')


def main() -> int:
    self_test()
    errors = policy_errors(ROOT)
    if errors:
        print("CI contract failed:", file=sys.stderr)
        for error in errors:
            print(f"  - {error}", file=sys.stderr)
        return 1
    print("CI contract passed: immutable actions, verified downloads, narrow writes")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
