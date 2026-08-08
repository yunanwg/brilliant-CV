#!/usr/bin/env python3
"""Generate api-reference.md from Typst doc-comments in src/*.typ files.

Parses tidy-style `///` doc-comments and `#let` signatures from source files
and produces a Markdown API reference page for MkDocs.

Usage:
    python generate-api-reference.py > docs/api-reference.md
    # or from project root:
    python docs/web/generate-api-reference.py > docs/web/docs/api-reference.md
"""

from __future__ import annotations

import re
import sys
from dataclasses import dataclass, field
from pathlib import Path

# Resolve project root (two levels up from this script)
SCRIPT_DIR = Path(__file__).resolve().parent
PROJECT_ROOT = SCRIPT_DIR.parent.parent

# Source files to parse, in order
SOURCE_FILES = [
    ("Entry Point Functions", PROJECT_ROOT / "src" / "lib.typ"),
    ("CV Components", PROJECT_ROOT / "src" / "cv.typ"),
    ("Utility Functions", PROJECT_ROOT / "src" / "utils" / "styles.typ"),
]

# The package root is the public contract. Internal modules and dependencies
# are not scanned for exports merely because they contain top-level bindings.
PUBLIC_API_SOURCE_FILE = PROJECT_ROOT / "src" / "lib.typ"

# Functions to include (public API only)
#
# Kept in sync with explicit root bindings in src/lib.typ and with the
# doc-comment sections extracted below.
PUBLIC_FUNCTIONS = {
    "cv",
    "letter",
    "cv-section",
    "cv-entry",
    "cv-entry-start",
    "cv-entry-continued",
    "cv-skill",
    "cv-skill-with-level",
    "cv-skill-tag",
    "cv-honor",
    "cv-publication",
    "h-bar",
    "overwrite-fonts",
}

# Match root functions and explicit aliases. Private bindings are filtered.
_ROOT_BINDING_RE = re.compile(r"^#let\s+([\w-]+)\s*(?:\(|=)")


def scan_public_exports() -> set[str]:
    """Scan explicit, non-private bindings in the package root."""
    exports: set[str] = set()
    for line in PUBLIC_API_SOURCE_FILE.read_text().splitlines():
        match = _ROOT_BINDING_RE.match(line)
        if match and not match.group(1).startswith("_"):
            exports.add(match.group(1))
    return exports


def check_public_functions_in_sync() -> None:
    """Fail fast if the hardcoded PUBLIC_FUNCTIONS allowlist drifts out of
    sync with the actual public exports in src/. Prevents a newly added
    public component from silently missing docs, or a stale/typo'd entry
    from lingering in PUBLIC_FUNCTIONS."""
    actual = scan_public_exports()
    missing = actual - PUBLIC_FUNCTIONS
    extra = PUBLIC_FUNCTIONS - actual
    if missing or extra:
        print(
            "PUBLIC_FUNCTIONS in generate-api-reference.py is out of sync "
            "with the public exports scanned from src/:",
            file=sys.stderr,
        )
        if missing:
            print(
                f"  missing from PUBLIC_FUNCTIONS (exported, undocumented): {sorted(missing)}",
                file=sys.stderr,
            )
        if extra:
            print(
                f"  extra in PUBLIC_FUNCTIONS (not actually exported): {sorted(extra)}",
                file=sys.stderr,
            )
        sys.exit(1)

# Every current signature parameter is part of the generated contract.
OMIT_PARAMS: set[str] = set()


@dataclass
class Param:
    name: str
    type: str
    description: str
    default: str | None = None


@dataclass
class Function:
    name: str
    description: str = ""
    params: list[Param] = field(default_factory=list)
    return_type: str = ""
    example: str = ""


def parse_doc_comment_block(lines: list[str], start: int) -> tuple[str, int]:
    """Extract consecutive /// lines starting at `start`. Returns (text, next_line_index)."""
    doc_lines = []
    i = start
    while i < len(lines) and lines[i].lstrip().startswith("///"):
        content = lines[i].lstrip().removeprefix("///")
        # Remove leading single space if present
        if content.startswith(" "):
            content = content[1:]
        doc_lines.append(content)
        i += 1
    return "\n".join(doc_lines), i


def parse_let_signature(lines: list[str], start: int) -> tuple[str, dict[str, str], int]:
    """Parse a #let function(param: default, ...) signature. Returns (name, {param: default}, next_line)."""
    # Collect lines until we find the closing ) or = or {
    sig_lines = []
    i = start
    paren_depth = 0
    while i < len(lines):
        line = lines[i]
        sig_lines.append(line)
        paren_depth += line.count("(") - line.count(")")
        if paren_depth <= 0:
            i += 1
            break
        i += 1

    sig = " ".join(l.strip() for l in sig_lines)

    # Extract function name
    name_match = re.match(r"#let\s+([\w-]+)", sig)
    if not name_match:
        return "", {}, i
    name = name_match.group(1)

    # Extract parameters between first ( and last )
    paren_start = sig.index("(")
    # Find matching close paren
    depth = 0
    paren_end = paren_start
    for ci, ch in enumerate(sig[paren_start:], paren_start):
        if ch == "(":
            depth += 1
        elif ch == ")":
            depth -= 1
            if depth == 0:
                paren_end = ci
                break

    param_str = sig[paren_start + 1 : paren_end].strip()
    if not param_str:
        return name, {}, i

    # Split params by comma (but not commas inside parens/brackets)
    params = {}
    current = []
    depth = 0
    for ch in param_str:
        if ch in "([{":
            depth += 1
            current.append(ch)
        elif ch in ")]}":
            depth -= 1
            current.append(ch)
        elif ch == "," and depth == 0:
            p = "".join(current).strip()
            if p:
                _add_param(params, p)
            current = []
        else:
            current.append(ch)
    p = "".join(current).strip()
    if p:
        _add_param(params, p)

    return name, params, i


def _add_param(params: dict[str, str], param_str: str):
    """Parse 'name: default' or 'name' and add to params dict."""
    # Skip .. args
    if param_str.startswith(".."):
        return
    if ":" in param_str:
        key, val = param_str.split(":", 1)
        params[key.strip()] = val.strip()
    else:
        params[param_str.strip()] = ""


def parse_doc_comment(text: str) -> tuple[str, list[Param], str, str]:
    """Parse a tidy doc-comment block into description, params, return_type, example."""
    lines = text.split("\n")
    description_lines = []
    params: list[Param] = []
    return_type = ""
    example_lines = []
    in_example = False

    for line in lines:
        # Return type
        if line.strip().startswith("-> "):
            return_type = line.strip().removeprefix("-> ").strip()
            continue

        # Example block
        if line.strip().startswith("```example"):
            in_example = True
            continue
        if in_example:
            if line.strip() == "```":
                in_example = False
                continue
            # Skip tidy preamble lines (>>>)
            if line.strip().startswith(">>>"):
                continue
            example_lines.append(line)
            continue

        # Parameter line: - name (type): description
        param_match = re.match(r"^- ([\w-]+)\s+\(([^)]+)\):\s*(.*)", line)
        if param_match:
            params.append(
                Param(
                    name=param_match.group(1),
                    type=param_match.group(2),
                    description=param_match.group(3),
                )
            )
            continue

        description_lines.append(line)

    # Clean up description: strip leading/trailing blank lines
    desc = "\n".join(description_lines).strip()
    example = "\n".join(example_lines).strip()

    return desc, params, return_type, example


def parse_source_file(filepath: Path) -> list[Function]:
    """Parse a .typ source file and extract public function docs."""
    lines = filepath.read_text().splitlines()
    functions: list[Function] = []
    i = 0

    while i < len(lines):
        # Look for doc-comment blocks
        if lines[i].lstrip().startswith("///"):
            doc_text, i = parse_doc_comment_block(lines, i)

            # Skip blank lines
            while i < len(lines) and lines[i].strip() == "":
                i += 1

            # Next should be a #let
            if i < len(lines) and lines[i].lstrip().startswith("#let "):
                name, sig_params, i = parse_let_signature(lines, i)

                if name not in PUBLIC_FUNCTIONS:
                    continue

                desc, doc_params, return_type, example = parse_doc_comment(doc_text)

                signature_names = set(sig_params)
                documented_names = {param.name for param in doc_params}
                undocumented = signature_names - documented_names
                stale = documented_names - signature_names
                if undocumented or stale:
                    details = []
                    if undocumented:
                        details.append(
                            "undocumented signature params: "
                            + ", ".join(sorted(undocumented))
                        )
                    if stale:
                        details.append(
                            "documented params absent from signature: "
                            + ", ".join(sorted(stale))
                        )
                    raise ValueError(f"{filepath}:{name}: " + "; ".join(details))

                # Merge defaults from signature into doc params.
                # `none` is a valid Typst default and must be preserved in the
                # generated table — filtering it out incorrectly renders the
                # cell as `—`, which conventionally means "no default, required".
                for p in doc_params:
                    if p.name in sig_params:
                        default = sig_params[p.name]
                        if default:
                            p.default = default

                functions.append(
                    Function(
                        name=name,
                        description=desc,
                        params=doc_params,
                        return_type=return_type,
                        example=example,
                    )
                )
        else:
            i += 1

    return functions


def format_function_md(func: Function) -> str:
    """Format a Function as a Markdown section."""
    lines = []
    lines.append(f"### `{func.name}()`")
    lines.append("")

    if func.description:
        # Convert tidy markup to Markdown
        desc = func.description
        # *text* -> **text** but avoid clobbering already-starred text
        desc = re.sub(r"(?<!\*)\*([^*]+)\*(?!\*)", r"**\1**", desc)
        lines.append(desc)
        lines.append("")

    # Parameter table
    visible_params = [p for p in func.params if p.name not in OMIT_PARAMS]
    if visible_params:
        lines.append("| Parameter | Type | Default | Description |")
        lines.append("|-----------|------|---------|-------------|")
        for p in visible_params:
            default = f"`{p.default}`" if p.default else "—"
            # Escape pipe characters in type and description for table cells
            ptype = p.type.replace("|", "\\|")
            desc = p.description.replace("|", "\\|")
            lines.append(f"| `{p.name}` | {ptype} | {default} | {desc} |")
        lines.append("")

    # Example code block
    if func.example:
        cleaned = func.example.strip()
        if cleaned:
            lines.append("```typ")
            lines.append(cleaned)
            lines.append("```")
            lines.append("")

    return "\n".join(lines)


def generate_api_reference() -> str:
    """Generate the full api-reference.md content."""
    sections = []
    sections.append("# API Reference")
    sections.append("")
    sections.append(
        "<!-- This file is auto-generated by generate-api-reference.py. Do not edit manually. -->"
    )
    sections.append("")
    sections.append(
        "This page documents the public Typst functions exported by brilliant-CV. "
        "For metadata keys read from `metadata.toml`, see the [Configuration Reference](configuration.md)."
    )
    sections.append("")
    sections.append(
        "Only the root exports documented here are compatibility commitments. "
        "Underscore-prefixed helpers and dependency symbols are implementation "
        "details. Import Font Awesome icons from `fontawesome` directly."
    )
    sections.append("")

    file_sections = []
    documented_functions: set[str] = set()
    for section_title, filepath in SOURCE_FILES:
        functions = parse_source_file(filepath)
        if not functions:
            continue
        for function in functions:
            if function.name in documented_functions:
                raise ValueError(f"duplicate public function: {function.name}")
            documented_functions.add(function.name)
        file_sections.append((section_title, functions))

    if documented_functions != PUBLIC_FUNCTIONS:
        missing = PUBLIC_FUNCTIONS - documented_functions
        unexpected = documented_functions - PUBLIC_FUNCTIONS
        details = []
        if missing:
            details.append("missing docs: " + ", ".join(sorted(missing)))
        if unexpected:
            details.append("unexpected docs: " + ", ".join(sorted(unexpected)))
        raise ValueError("public API documentation mismatch: " + "; ".join(details))

    for idx, (section_title, functions) in enumerate(file_sections):
        sections.append(f"## {section_title}")
        sections.append("")

        for func in functions:
            sections.append(format_function_md(func))

        if idx < len(file_sections) - 1:
            sections.append("---")
            sections.append("")

    return "\n".join(sections)


if __name__ == "__main__":
    check_public_functions_in_sync()
    output = generate_api_reference()
    # If stdout is a terminal, also write to file
    outfile = SCRIPT_DIR / "docs" / "api-reference.md"
    outfile.write_text(output.rstrip() + "\n")
    print(f"Generated {outfile}", file=sys.stderr)
