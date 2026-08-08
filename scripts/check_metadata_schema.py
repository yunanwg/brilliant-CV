#!/usr/bin/env python3
"""Validate the shipped metadata schema and its compatibility contract."""

from __future__ import annotations

import copy
import json
import tomllib
from pathlib import Path

try:
    import jsonschema
except ImportError as error:  # pragma: no cover - runner setup owns this path
    raise SystemExit(
        "jsonschema is required; run `just schema-check` from the repository root"
    ) from error


ROOT = Path(__file__).resolve().parent.parent
SCHEMA_PATH = ROOT / "template" / "metadata.toml.schema.json"
PROFILE_PATHS = sorted((ROOT / "template").glob("profile_*/metadata.toml"))
SCHEMA_DIRECTIVE = "#:schema ../metadata.toml.schema.json"


def load_profile(path: Path) -> dict[str, object]:
    first_line = path.read_text().splitlines()[0]
    if first_line != SCHEMA_DIRECTIVE:
        raise AssertionError(
            f"{path.relative_to(ROOT)} must start with {SCHEMA_DIRECTIVE!r}"
        )
    with path.open("rb") as stream:
        return tomllib.load(stream)


def expect_rejected(
    validator: jsonschema.Draft7Validator,
    label: str,
    value: dict[str, object],
) -> None:
    if not list(validator.iter_errors(value)):
        raise AssertionError(f"schema unexpectedly accepted {label}")


def main() -> int:
    schema = json.loads(SCHEMA_PATH.read_text())
    jsonschema.Draft7Validator.check_schema(schema)
    validator = jsonschema.Draft7Validator(schema)

    if not PROFILE_PATHS:
        raise AssertionError("no template profiles found")

    profiles = [load_profile(path) for path in PROFILE_PATHS]
    for path, profile in zip(PROFILE_PATHS, profiles, strict=True):
        validator.validate(profile)
        if profile.get("inject"):
            raise AssertionError(
                f"{path.relative_to(ROOT)} must keep injection disabled by default"
            )
        print(f"validated {path.relative_to(ROOT)}")

    base = profiles[0]

    unknown_root = copy.deepcopy(base)
    unknown_root["unknown_root"] = True
    expect_rejected(validator, "an unknown root key", unknown_root)

    unknown_nested = copy.deepcopy(base)
    unknown_nested["layout"]["header"]["headerAlign"] = "left"
    expect_rejected(validator, "an unknown nested key", unknown_nested)

    unknown_info = copy.deepcopy(base)
    unknown_info["personal"]["info"]["website"] = "example.com"
    expect_rejected(validator, "an unknown personal-info key", unknown_info)

    invalid_paper = copy.deepcopy(base)
    invalid_paper["layout"]["paper_size"] = "#abc"
    expect_rejected(validator, "an invalid paper size", invalid_paper)

    missing_personal = copy.deepcopy(base)
    del missing_personal["personal"]
    expect_rejected(validator, "missing required personal data", missing_personal)

    malformed_custom = copy.deepcopy(base)
    malformed_custom["personal"]["info"]["custom-test"] = {
        "awesomeIcon": "star"
    }
    expect_rejected(validator, "a custom item without text", malformed_custom)

    unknown_custom_field = copy.deepcopy(base)
    unknown_custom_field["personal"]["info"]["custom-test"] = {
        "awesomeIcon": "star",
        "text": "Custom",
        "other": True,
    }
    expect_rejected(
        validator, "an unknown field inside a custom item", unknown_custom_field
    )

    empty_keywords = copy.deepcopy(base)
    empty_keywords["inject"] = {"injected_keywords_list": []}
    expect_rejected(validator, "an empty injection keyword list", empty_keywords)

    valid_custom_info = copy.deepcopy(base)
    valid_custom_info["personal"]["info"]["custom-test"] = {
        "text": "Custom image icon supplied from cv.typ",
        "link": "https://example.com",
    }
    validator.validate(valid_custom_info)

    valid_module_data = copy.deepcopy(base)
    valid_module_data["custom"] = {
        "portfolio": {"show_case_studies": True},
        "theme_variant": "compact",
    }
    validator.validate(valid_module_data)

    print(
        "validated strict core fields, disabled-by-default injection, "
        "and explicit custom namespaces"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
