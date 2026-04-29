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
]

# Extra utility functions to document (not auto-extracted)
UTILITY_SECTION = """\
---

## Utility Functions

### `h-bar()`

Renders a vertical bar separator (`|`) for use inside skill entries.

```typ
#import "@preview/brilliant-cv:4.0.0": h-bar

[Python #h-bar() SQL #h-bar() Tableau]
```
"""

# Functions to include (public API only)
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
}

# Parameters to omit from the public docs (internal/deprecated)
OMIT_PARAMS = {
    "metadata",
    "awesome-colors",
    "awesomeColors",
    "profilePhoto",
    "myAddress",
    "recipientName",
    "recipientAddress",
    "refStyle",
    "refFull",
    "keyList",
}


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

    # Example code block (strip internal details like metadata: _metadata)
    if func.example:
        cleaned_lines = []
        for line in func.example.splitlines():
            # Remove standalone metadata param lines (e.g. "    metadata: _metadata,")
            if re.match(r"^\s*metadata:\s*_metadata,?\s*$", line):
                continue
            # Remove inline metadata param from function calls
            line = re.sub(r",\s*metadata:\s*_metadata", "", line)
            cleaned_lines.append(line)
        cleaned = "\n".join(cleaned_lines).strip()
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

    file_sections = []
    for section_title, filepath in SOURCE_FILES:
        functions = parse_source_file(filepath)
        if not functions:
            continue
        file_sections.append((section_title, functions))

    for idx, (section_title, functions) in enumerate(file_sections):
        sections.append(f"## {section_title}")
        sections.append("")

        for func in functions:
            sections.append(format_function_md(func))

        if idx < len(file_sections) - 1:
            sections.append("---")
            sections.append("")

    # Add utility section
    sections.append(UTILITY_SECTION)

    return "\n".join(sections)


if __name__ == "__main__":
    output = generate_api_reference()
    # If stdout is a terminal, also write to file
    outfile = SCRIPT_DIR / "docs" / "api-reference.md"
    outfile.write_text(output + "\n")
    print(f"Generated {outfile}", file=sys.stderr)
