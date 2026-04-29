# Project Instructions

Brilliant CV is a **Typst package** (`@preview/brilliant-cv`) for creating modular, multilingual CVs and cover letters. Published to Typst Universe.

## Before You Start

Run `just link` before any local development. This registers the local package with Typst's resolver. Without it, all imports fail. Run `just` to see all available commands.

## Critical Architecture

**`src/` is the published package. `template/` is the user-facing starter project.** They are separate concerns:
- `src/lib.typ` — Package entry point, exports `cv()` and `letter()`
- `template/profile_<name>/metadata.toml` — Each profile is a complete, self-contained CV configuration. v4 has no root `metadata.toml`.
- `template/profile_<name>/*.typ` — Content modules per profile (education, professional, projects, certificates, publications, skills)

Changes to `src/` affect all downstream users. Never break backward compatibility without a deprecation path.

## Things You Will Get Wrong Without Reading This

### Schema migration guards panic, they don't silently fall back
`src/lib.typ:_check-v3-legacy` panics on v3-only fields (`language`, `non_latin_font`, `non_latin_name`, `[lang.*]`). The same applies to v2 inject keys (`inject_ai_prompt`, `inject_keywords`). These are **intentional** — do not "fix" them. The v4 design picks panic-with-migration-message over silent fallback to avoid hiding behavior changes.

### Some files are auto-generated — do not edit manually
- `docs/web/docs/api-reference.md` ← generated from `src/` doc-comments
- `docs/web/docs/configuration.md` ← generated from `template/profile_en/metadata.toml` comments (profile_en is the canonical reference)

Regenerate with `just docs-generate`. Edit the **source comments**, not the output files.

### Each profile's metadata.toml is the single source of truth for that profile
All user configuration flows through `template/profile_<name>/metadata.toml`. v4 has no merging or inheritance — one profile = one complete CV configuration. When adding new config options, update the comments in `template/profile_en/metadata.toml` first (it drives docs generation), then mirror to other profiles as needed.

### Tests live in `tests/` and use tytanic + a panic shell runner
Visual tests run in Docker (`tests/Dockerfile`) on both maintainer machines and CI — refs are pixel-deterministic, no cross-OS noise to absorb. `just test` for the full suite (Docker). `just test-fast` for native sub-second feedback (panics + units only). `just fmt-check` runs typstyle in the same image. CJK regression tests use Noto Sans CJK SC (Linux baseline) instead of macOS Heiti SC — Heiti SC visual fidelity is verified manually by the maintainer with `just dev`. See `tests/README.md` for the full layout.

## Conventions

- Conventional commits (`feat:`, `fix:`, `docs:`, etc.)
- Run `just build && just test` before committing
- Don't commit PDFs (handled by .gitignore and pre-commit hooks)
- Tytanic ref PNGs live next to each `test.typ`; commit intentional regenerations alongside the layout change that caused them
- Read `CONTRIBUTING.md` for the full contribution workflow
