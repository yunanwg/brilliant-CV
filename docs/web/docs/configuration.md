# Configuration Reference — `profile_<name>/metadata.toml`

Each `profile_<name>/metadata.toml` is a **complete, self-contained** configuration for that CV variant. There is no shared root or merge mechanism — looking at one file shows the full effective config for that profile.

Switch profiles at compile time:

```bash
typst compile cv.typ --input profile=fr
```

To add a new profile, copy `profile_en/` to `profile_<new>/` and edit the fields that differ.

## How to read this page

The reference below is the canonical [`template/profile_en/metadata.toml`](https://github.com/yunanwg/brilliant-CV/blob/main/template/profile_en/metadata.toml) included verbatim — comments in the TOML *are* the field documentation. The web documentation pulls from it via a live snippet, so the field descriptions stay aligned with the starter project.

Every other shipped profile (`profile_fr`, `profile_de`, `profile_it`, `profile_zh`) follows the same schema; differences are in field *values*, not field *names*.

## Annotated reference

```toml
--8<-- "template/profile_en/metadata.toml"
```

## Schema

A strict JSON Schema is included in every initialized starter at [`template/metadata.toml.schema.json`](https://github.com/yunanwg/brilliant-CV/blob/main/template/metadata.toml.schema.json). Each profile uses a local `#:schema ../metadata.toml.schema.json` directive, so supported editors (Helix, Neovim with Taplo, or VS Code with Even Better TOML) provide validation and autocomplete without depending on the repository's `main` branch or network access.

Core package-owned namespaces are closed: unknown keys and invalid value types are reported by the editor. Put data used only by your own modules under the open top-level `[custom]` namespace. At compile time, `cv()` and `letter()` additionally guard v3-removed fields with migration errors (see the [Migration Guide](migration.md)); Typst itself does not apply JSON Schema while compiling.
