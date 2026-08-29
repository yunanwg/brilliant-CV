# Project Instructions

Brilliant CV is a **Typst package** (`@preview/brilliant-cv`) for creating modular, multilingual CVs and cover letters. Published to Typst Universe.

## Before You Start

Run `just link` before any local development. This registers the local package with Typst's resolver. Without it, all imports fail.

## Commands

`just` with no argument lists every recipe. These are the ones you need:

| Command | Use it when | Notes |
|---|---|---|
| `just link` | Once, before anything else | Without it every import fails |
| `just build` | You changed `src/` or `template/` | Compiles both starter entrypoints |
| `just test-fast` | Inner loop | Native, sub-second. Panics + units only — runs **no** visual regression tests |
| `just test` | Before committing | Full suite, tytanic visual + panic smoke. Needs a running Docker daemon |
| `just test-update` | A layout change moved pixels on purpose | Regenerates ref PNGs in Docker; review the new PNGs before committing |
| `just fmt-check` | Before committing | typstyle gate, same image as CI |
| `just docs-generate` | You changed doc-comments in `src/` or comments in `template/profile_en/metadata.toml` | Regenerates the two generated pages |
| `just verify-release` | Preparing a release | Full pre-release contract |

## Critical Architecture

**`src/` is the published package. `template/` is the user-facing starter project.** They are separate concerns:
- `src/lib.typ` — Package entry point, exports `cv()` and `letter()`
- `src/cv.typ`, `src/letter.typ` — Component functions (`cv-entry`, `cv-honor`, `cv-skill*`, `cv-publication`, …)
- `template/profile_<name>/metadata.toml` — Each profile is a complete, self-contained CV configuration. v4 has no root `metadata.toml`.
- `template/profile_<name>/*.typ` — Content modules per profile (education, professional, projects, certificates, publications, skills)

Changes to `src/` affect all downstream users. Never break backward compatibility without a deprecation path.

## Things You Will Get Wrong Without Reading This

### Schema migration guards panic, they don't silently fall back
`src/lib.typ:_check-v3-legacy` panics on v3-only fields (`language`, `non_latin_font`, `non_latin_name`, `[lang.*]`). The same applies to v2 inject keys (`inject_ai_prompt`, `inject_keywords`). These are **intentional** — do not "fix" them. The v4 design picks panic-with-migration-message over silent fallback to avoid hiding behavior changes.

### Two documentation pages are generated — edit the source, not the output
- `docs/web/docs/api-reference.md` ← generated from `src/` doc-comments
- `docs/web/docs/configuration.md` ← generated from `template/profile_en/metadata.toml` comments (profile_en is the canonical reference)

Edit those source comments, then run `just docs-generate`. Every other page under `docs/web/docs/` is hand-written.

### Each profile's metadata.toml is the single source of truth for that profile
All user configuration flows through `template/profile_<name>/metadata.toml`. v4 has no merging or inheritance — one profile = one complete CV configuration. When adding new config options, update the comments in `template/profile_en/metadata.toml` first (it drives docs generation), then mirror to other profiles as needed.

### Typst snippets in `docs/` are compile-tested by hand, not by CI
`just docs-check` compiles the snippets in the generated `api-reference.md` only. For a snippet you write anywhere else in `docs/`, drop it into a temp `.typ`, set up `cv-metadata.update(minimal-metadata)` from `tests/common.typ`, and run `typst compile --root . <file>` inside the test image. Don't ship code from memory — take every public function name and parameter from the actual signature in `src/`, and match the file you check against the import the snippet uses.

### Visual tests are pixel-deterministic because they run in Docker
Refs are generated in `tests/Dockerfile` on both maintainer machines and CI, so there is no cross-OS noise to absorb. `just test-fast` skipping the visual suite is the main way a regression slips through locally. CJK regression tests use Noto Sans CJK SC (Linux baseline) instead of macOS Heiti SC — Heiti SC visual fidelity is verified manually by the maintainer with `just dev`. See `tests/README.md` for the full layout.

### Releases are a PR flow, not a local tag push
From a clean checkout of the latest `origin/main`: `just prepare-release <version>` updates the manifest and current-version examples only, then `just verify-release`. Review and merge that as a normal PR, and only then create the `v<version>` tag on that exact `main` commit. The tag workflow fails closed if the tag, manifest, starter imports, and documentation disagree. Full contract in [`CONTRIBUTING.md` §6](CONTRIBUTING.md).

## Public API Design

Brilliant CV deliberately balances simplicity against flexibility. Before adding a public parameter or configuration field:

- First check whether existing components, content composition, or a documented recipe can express the use case clearly.
- Add new API only for recurring needs that cannot be composed cleanly and have a stable, broadly useful meaning.
- Avoid adding a separate option for every isolated styling preference; each option becomes a compatibility and documentation commitment.
- When new API is justified, keep the surface minimal, preserve backward compatibility, document it, and add a regression test.

See [`CONTRIBUTING.md` §4.2](CONTRIBUTING.md) for the contributor-facing rationale and decision checklist.

## Documentation Style

The hand-written pages under `docs/web/docs/` follow ASD-STE100 Simplified Technical English, with a fixed terminology table and a rule against rewriting code blocks. Read [`CONTRIBUTING.md` §4.4](CONTRIBUTING.md) before you write prose there — the terminology choices are already applied across the site, and CI does not gate them.

## Conventions

- Conventional commits (`feat:`, `fix:`, `docs:`, etc.)
- Run `just build && just test` before committing
- Don't commit PDFs (handled by `.gitignore` and pre-commit hooks)
- Tytanic ref PNGs live next to each `test.typ`; commit intentional regenerations alongside the layout change that caused them
- When fixing a reported issue, add a regression test (tytanic ref or panic shell) that reproduces the reported scenario in the same PR. Skip only when the change is docs-only or policy-only.
- Read `CONTRIBUTING.md` for the full contribution workflow
