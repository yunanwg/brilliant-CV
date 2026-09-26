# CV Workspace

This folder is a CV and cover-letter workspace. It was created with
`typst init @preview/brilliant-cv`. The package renders the documents. This
folder and its content belong to the user.

## Layout

| Path | Holds |
|---|---|
| `profile_<name>/metadata.toml` | Identity, contact data, and layout settings of one profile |
| `profile_<name>/*.typ` | CV content: education, experience, projects, skills |
| `cv.typ`, `letter.typ` | Entry points. `--input profile=<name>` selects the profile (default `en`) |
| `assets/` | Photo, logos, signature, bibliography |

For a tailored application, keep one folder per job, for example
`applications/<company>/` with the posting, a `cv.typ`, and a `letter.typ`.
Keep `profile_<name>/` as the single source of truth and change facts there
only.

## Rules

1. **Do not invent facts.** Tailor by selecting, ordering, and rephrasing
   what the profile already contains. If a posting asks for something that
   the profile does not show, tell the user. Do not add it.
2. **Check the profile before you use it.** Dates, degrees, locations, and
   header badges must agree with each other. Report a contradiction to the
   user instead of choosing a version yourself.
3. **Take the API from the installed package, not from memory.** The
   `#import "@preview/brilliant-cv:<version>"` lines pin the version. The
   doc-comments in that version's `src/lib.typ` and `src/cv.typ` are the
   reference. Typst caches the package at `<cache>/typst/packages/preview/brilliant-cv/<version>/`,
   where `<cache>` is `~/Library/Caches` (macOS), `~/.cache` (Linux), or
   `%LOCALAPPDATA%` (Windows). The field reference for `metadata.toml` is
   `metadata.toml.schema.json` in this folder.
4. **Verify every change by compiling.**
   - `typst compile cv.typ --input profile=<name>`
   - For a file in a subfolder that reads `../../profile_<name>/`, add
     `--root .` and run from this folder:
     `typst compile --root . applications/<company>/cv.typ`
   - To check the page count and the layout, compile to PNG, one file per
     page: `typst compile cv.typ "cv-{p}.png"`. Typst does not create a
     missing output folder.
5. **Keep personal data local.** A scanned signature, a phone number, and
   application folders do not belong in a public repository. Before the
   first commit, add `applications/`, `*.pdf`, and `assets/signature.*` to a
   `.gitignore` in this folder.

## Useful patterns

- Override a profile value for one application without editing the
  profile: `#metadata.insert("header_quote", "…")` before `cv.with(metadata)`.
- The cover-letter body is 12pt. `[layout] font_size` applies to the CV only.
- To keep the closing, the signature, and the name together on one page,
  put them in `#block(breakable: false)[…]` at the end of the letter.
