# Contributing to Brilliant CV

Thanks for helping keep Brilliant CV polished! This document explains how to run the template locally, adapt it to your needs, and submit improvements upstream.

> **Why the extra setup?**  
> Typst packages are resolved by namespace (`@preview/<name>:<version>`) and normally live inside Typst’s cache/data directories, so the compiler cannot load this template straight from the repository without a link step. The `justfile` automates that link by calling `utpm ws link --force --no-copy`, which registers the workspace as the authoritative copy of `@preview/brilliant-cv:<version>` on your machine. See the Typst package repository docs for more background on how package resolution works.  
> [Typst packages](https://github.com/typst/packages)

---

## 1. Prerequisites

- [Typst](https://github.com/typst/typst) CLI `>= 0.14.0` (matches `typst.toml`)
- [utpm](https://github.com/Thumuss/utpm) (Workspace/package manager used by the automation)
- Fonts listed in `README.md` (Roboto, Source Sans 3, Font Awesome 6)
- macOS/Linux shell with `just` (or run the equivalent commands manually)

For running the test suite locally:

- **Docker** (or OrbStack / Colima / Podman) — `just test` builds and runs `tests/Dockerfile`, the same Linux image CI uses. One source of truth for typst / tytanic / typstyle versions and font installation, so visual-regression refs are pixel-deterministic across all machines. First build is ~3 min; later runs are cached.
- [tytanic](https://github.com/typst-community/tytanic) `>= 0.3` and [typstyle](https://github.com/typstyle-rs/typstyle) `0.14.4` are **optional** for the native fast-path (`just test-fast` — panic + unit tests, sub-second). Install via `cargo install tytanic --version "^0.3"` and `brew install typstyle`. Visual tests always run in Docker.
- A C-locale `bash` is enough for the panic-fixture smoke tests (`tests/panics/run.sh`, used by `just test-fast`).

Optional but helpful:

- `pre-commit`, `typos` (recommended tools already mentioned in the README)

---

## 2. Local development workflow

1. **Clone the repo**
   ```bash
   git clone https://github.com/yunanwg/brilliant-CV.git
   cd brilliant-CV
   ```

2. **Link the package into Typst**
   ```bash
   just link
   # or run: utpm ws link --force --no-copy
   ```
   This step is required before Typst can resolve `#import "@preview/brilliant-cv:<version>"`.

3. **Iterate with watch mode**
   ```bash
   just dev
   ```
   - Starts `typst watch template/cv.typ temp/cv.pdf` so you can edit files while the PDF refreshes.
   - On exit it compiles one last time, unlinks the workspace, and clears temporary artifacts.

4. **One-off builds / preview**
   - `just build` → compile `template/cv.typ` into `temp/cv.pdf`
   - `just open` → build then open the resulting PDF
   - `just watch` → plain `typst watch` without the lifecycle extras
   - `just reset` → a convenience combo of `just unlink` + `just clean`

> **Tip:** If Typst refuses to resolve the package after a reboot, re-run `just link`. The registration lives outside the repo and can be pruned by Typst itself.

---

## 3. Repository layout

- `src/` – core reusable components (`cv`, `letter`, utilities). Keep backward compatibility: prefer adding new parameters instead of breaking existing ones, and mirror the “new + deprecated alias” pattern already in `src/lib.typ`.
- `template/` – the bootstrapped project users receive (`cv.typ`, `letter.typ`, profiles, assets, `metadata.toml`). Any user-facing customization should be expressed here or via metadata defaults.
- `template/profile_<lang>/` – self-contained CV variant: complete `metadata.toml` plus content modules. Add new samples here when you introduce profile-specific features. There is no shared root `metadata.toml` in v4.
- `tests/` – tytanic-driven test suite plus shell-script panic smoke tests. See `tests/README.md` for the full layout. Excluded from the published package via `typst.toml` `exclude`.
- `docs/` – Typst documentation for the API (regenerate if you alter the public surface).
- `justfile` – task runner (see Section 2).

---

## 4. Making changes

### 4.1 Personal customizations

If you simply want to adapt the template to your own profile:

- Edit `template/profile_<name>/metadata.toml` (each profile holds its complete configuration: layout, injection, personal info, localized strings).
- Update the relevant `profile_<name>/*.typ` files with your content.
- Keep `src/` untouched unless you plan to submit the enhancement back.

### 4.2 Feature / bug-fix contributions

1. **Create a branch** and make your changes in `src/` and/or `template/`.
2. **Document anything user-facing**:
   - Update `README.md` (or `docs/`) for new parameters.
   - Add comments to `metadata.toml` if you introduce new knobs.
3. **Keep compatibility**:
   - For renamed parameters, follow the aliasing approach already used in `src/lib.typ`.
   - Don’t remove template options without deprecation notes.
4. **Run the checks**:
   ```bash
   just build       # compile the template once
   just test        # full suite — tytanic visual + panic shell smoke tests (Docker)
   just fmt-check   # typstyle gate (Docker; same image as CI)
   ```
   Tighter inner loops:
   - `just test-fast` — compile-only tests (panics + units), runs natively, sub-second; needs `tt` + `typst` on PATH
   - `just test-filter 'components/*'` — visual subset, runs in Docker
   - `just test-update` — regenerate ref PNGs in Docker after intentional layout changes; review the new PNGs visually before committing
   - `just test-shell` — drop into a shell inside the test image for debugging

5. **Commit using conventional commits** (the repo follows conventional commit messages for history clarity).
6. **Open a PR** describing the change, how to test it, and screenshots/PDF snippets if the visual output changed.

---

## 5. Submitting PRs

Before pushing:

- Ensure `temp/` and generated PDFs are excluded (already covered by `.gitignore`, but double-check).
- Re-run `just link` if CI instructions include `typst compile` steps—missing links are the most common local failure mode.
- If you tweak the automation (`justfile`, `utpm` usage), explain the reasoning in the PR since other contributors rely on this workflow to bypass Typst’s package lookup restrictions.

After CI passes, a maintainer will review. Be ready to:

- Rebase / squash based on review requests.
- Provide snippets of rendered output if the diff touches styles or layouts.

Thanks again for contributing! If you hit any setup hurdles, start a discussion or issue before opening a PR so we can keep these docs accurate.
