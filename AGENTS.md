# Project Instructions

Brilliant CV is a **Typst package** (`@preview/brilliant-cv`) for creating modular, multilingual CVs and cover letters. Published to Typst Universe.

## Before You Start

Run `just link` before any local development. This registers the local package with Typst's resolver. Without it, all imports fail. Run `just` to see all available commands.

## Critical Architecture

**`src/` is the published package. `template/` is the user-facing starter project.** They are separate concerns:
- `src/lib.typ` — Package entry point, exports `cv()` and `letter()`
- `template/profile_<name>/metadata.toml` — Self-contained configuration for each CV variant (v4 has no root `metadata.toml`)
- `template/profile_<name>/*.typ` — Content modules per profile

Changes to `src/` affect all downstream users. Never break backward compatibility without a deprecation path.

## Things You Will Get Wrong Without Reading This

### Deprecated parameters use panic(), not silent aliasing
In `src/lib.typ`, deprecated parameters trigger `panic()` with migration instructions. This is **intentional** — do not "fix" these panics. Example: `inject_ai_prompt` → `custom_ai_prompt_text`.

### Some files are auto-generated — do not edit manually
- `docs/web/docs/api-reference.md` ← generated from `src/` doc-comments
- `docs/web/docs/configuration.md` ← generated from `template/profile_en/metadata.toml` comments

Regenerate with `just docs-generate`. Edit the **source comments**, not the output files.

### profile_en/metadata.toml is the canonical reference
All user configuration flows through each profile's `metadata.toml`. The English profile (`template/profile_en/metadata.toml`) is the most heavily annotated and is what `generate-configuration.py` reads to generate the public configuration reference. When adding config options, update the comments in `profile_en/metadata.toml` first.

Other profiles (`profile_fr`, `profile_zh`, etc.) are standalone copies — when you add a config field that needs a value in every profile, update each profile file.

### Typography is fully explicit in v4 — no language branch
v4 removed the `_is-non-latin()` whitelist (zh/ja/ko/ru). All typography decisions are now driven by explicit fields the user sets in their profile metadata: `[layout.fonts]` for the font fallback chain, `[layout.section] title_highlight` for section title style, `[personal] display_name` for non-split header rendering, and `[layout] date_width` for the entry date column. When touching font or layout code, test with `profile_zh` (the canonical mixed-script profile in `template/`).

## Conventions

- Conventional commits (`feat:`, `fix:`, `docs:`, etc.)
- Run `just build` before committing to verify compilation
- Don't commit PDFs (handled by .gitignore and pre-commit hooks)
- Use `just compare` for visual regression testing before public-facing changes
- Read `CONTRIBUTING.md` for the full contribution workflow
