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
   - To check the page count without rendering (Typst 0.15+):
     `typst eval --input brilliant-cv-query=1 'query(<brilliant-cv>).last().value.pages' --in cv.typ`.
     On Typst 0.14, use `typst query cv.typ '<brilliant-cv>' --field value --input brilliant-cv-query=1`
     and read `pages` from the last element. Each element also reports the
     `page` on which it ends, so you can list what spilled to page 2; the
     `cv()` doc-comment lists the fields.
   - To see the layout, compile to PNG, one file per page:
     `typst compile --root . applications/<company>/cv.typ "applications/<company>/cv-{p}.png"`.
     Typst does not create a missing output folder.
5. **Keep personal data local.** A scanned signature, a phone number, and
   application folders do not belong in a public repository. Before the
   first commit, add `applications/`, `*.pdf`, and `assets/signature.*` to a
   `.gitignore` in this folder.

## Tailor a CV for one application

1. Copy `cv.typ` and `letter.typ` to `applications/<company>/`. In both
   copies, change `"profile_"` to `"../../profile_"` and `"assets/` to
   `"../../assets/`.
2. Keep only the modules you need, or paste the chosen entries from
   `profile_<name>/*.typ` into this file. Do not edit the profile for one job.
3. Override a profile value for this application only:
   `#metadata.insert("header_quote", "…")` before `cv.with(metadata)`.
4. In the letter copy, set `recipient-name`, `recipient-address`, `subject`,
   and a fixed `date:` (the default is today, so it changes on every compile).
5. Verify with the commands in rule 4 from this folder, with `--root .`.

## Useful patterns

- The cover-letter body is 12pt. `[layout] font_size` applies to the CV only.
- To keep the closing, the signature, and the name together on one page,
  put them in `#block(breakable: false)[…]` at the end of the letter.
- Letter addresses use small caps by default, which prints "ß" as "SS" and
  e-mail addresses in capitals. Pass `address-style: "normal"` to keep them
  as written.
