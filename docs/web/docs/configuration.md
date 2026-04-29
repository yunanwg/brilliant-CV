# Configuration Reference — `profile_<name>/metadata.toml`

Each `profile_<name>/metadata.toml` is a **complete, self-contained** configuration for that CV variant. There is no shared root or merge mechanism — looking at one file shows the full effective config for that profile.

Switch profiles at compile time:

```bash
typst compile cv.typ --input profile=fr
```

To add a new profile, copy `profile_en/` to `profile_<new>/` and edit the fields that differ.

## How to read this page

The reference below is the canonical [`template/profile_en/metadata.toml`](https://github.com/yunanwg/brilliant-CV/blob/main/template/profile_en/metadata.toml) included verbatim — comments in the TOML *are* the field documentation. This file is the source of truth: the docs site and the offline PDF reference (`docs/pdf/docs.typ` Section 6) both pull from it via live snippets, so you can never read a stale field description here.

Every other shipped profile (`profile_fr`, `profile_de`, `profile_it`, `profile_zh`) follows the same schema; differences are in field *values*, not field *names*.

## Annotated reference

```toml
--8<-- "template/profile_en/metadata.toml"
```

## Schema

A JSON Schema is also published at [`metadata.toml.schema.json`](https://github.com/yunanwg/brilliant-CV/blob/main/metadata.toml.schema.json). If your editor supports `#:schema` directives (helix, neovim with taplo, VS Code with Even Better TOML), you'll get inline validation, autocomplete, and error highlighting on every `metadata.toml`.

The schema is enforced at *compile time* by `cv()` and `letter()` for v3-removed fields (panic-with-migration-message — see [Migration Guide](migration.md)) but TOML key typos are silently ignored by typst's TOML parser, so the JSON Schema is your first line of defense against `headerAlign` (wrong) vs `header_align` (correct).
