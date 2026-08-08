# Getting Started — Your First CV in 10 Minutes

## Step 1: Initialize the Project

On your local system, create the project with this command:

```bash
typst init @preview/brilliant-cv
```

To use a specific release, add its version number. All releases after 2.0.0 are supported:

```bash
typst init @preview/brilliant-cv:4.1.0
```

## Step 2: Install Fonts

Install these fonts. Typst needs them to render the CV correctly:

- [Roboto](https://fonts.google.com/specimen/Roboto)
- [Source Sans 3](https://fonts.google.com/specimen/Source+Sans+3) (or Source Sans Pro)
- [Font Awesome 7 Free desktop fonts](https://fontawesome.com/download) (Regular, Solid, and Brands OTF files)

For Typst Web, upload the three Font Awesome OTF files to your project. For
local compilation, install the same files on your operating system. If these
fonts are absent, the contact icons render as boxes.

## Step 3: File Structure Map

After this step, your project contains these files:

| File / Directory | Purpose |
|-----------------|---------|
| `cv.typ` | Entry point. Edit it to add or remove modules. |
| `letter.typ` | Cover letter entry point |
| `profile_en/metadata.toml` | Complete configuration for the English profile |
| `profile_en/*.typ` | Your English content modules. Edit these files. |
| `profile_<name>/...` | Other profile variants (fr, de, it, and zh are examples) |
| `assets/` | Your profile photo and logos |

!!! tip
    Do not edit the package source files under `@preview/brilliant-cv`. The Typst package manager controls these files.

!!! warning "Keep personal files out of public repositories"
    Many people keep their completed CV project in a public git repository
    (see Step 8). The `assets/` directory then holds a real profile photo. If
    you use `letter.typ`, it also holds a scanned signature. Both files are
    sensitive. Use a private repository, or add the real files to
    `.gitignore` and commit placeholders.

## Step 4: Configure profile_en/metadata.toml

You set all options for the English profile in `profile_en/metadata.toml`. This file is a **complete, self-contained CV configuration**. The [Configuration Reference](configuration.md) lists every field.

Set these fields first:

- `awesome_color` — your accent color (`"skyblue"`, `"red"`, `"nephritis"`, `"concrete"`, `"darknight"`)
- `first_name` / `last_name` — your name in the header
- `[personal.info]` — your contact details (email, phone, GitHub, LinkedIn, and more)
- `header_quote` — the italic line below your name
- `cv_footer` / `letter_footer` — the text in the footer

## Step 5: Add Your First Entry

Open `profile_en/education.typ`. Replace its content with this code:

```typ
#import "@preview/brilliant-cv:4.1.0": cv-section, cv-entry

#cv-section("Education")

#cv-entry(
  title: [Master of Data Science],
  society: [University of California],
  date: [2018 - 2020],
  location: [USA],
  description: list(
    [Thesis: Predicting Customer Churn using ML],
  ),
)
```

Each profile module file imports from `@preview/brilliant-cv` and makes `cv-*` calls. The profile contains these modules: `education.typ`, `professional.typ`, `projects.typ`, `certificates.typ`, `publications.typ`, and `skills.typ`. `cv.typ` includes them in that order.

To add a new section, create a new module file under `profile_en/`. Then add its name to the `import-modules((...))` call in `cv.typ`.

## Step 6: Compile

```bash
typst compile cv.typ
```

## Step 7: (Optional) Add More Profiles

If you keep CVs in more than one language, or for different target roles, copy `profile_en/` to `profile_<name>/`. Then edit the fields that are different. Each profile is independent, and there is no shared root configuration. For more information, see [Recipes → Adding a New Profile](recipes.md#adding-a-new-profile).

## Step 8: Go Beyond

These steps are optional:

1. Use `git` to manage your project. You can then track changes and tag releases of your CV (`git tag cv-v1`, `git tag cv-v2`).
2. Use [`typstyle`](https://github.com/typstyle-rs/typstyle) and `pre-commit` to keep the format of your `.typ` files consistent.
3. If your CV is in English, use [`typos`](https://github.com/crate-ci/typos) to find spelling mistakes.
4. Configure CI to compile your CV on each push. See [Recipes → CI/CD with GitHub Actions](recipes.md#cicd-with-github-actions).

## 中文快速上手 (Chinese quickstart)

The template contains `profile_zh/` as an example. Copy that directory, or
copy `profile_en/` to `profile_zh/` and edit `metadata.toml`. v4 has no
automatic "language" mode. You set the fonts, the name layout, the section
style, and the width of the date column explicitly:

```toml
[personal]
display_name = "王道尔"        # overrides the Latin first/last name split

[layout]
date_width = "4.7cm"          # wider column fits Chinese month/year strings

[layout.fonts]
regular_fonts = ["Source Sans 3", "Heiti SC"]  # Latin + CJK fallback chain
header_font = "Heiti SC"

[layout.section]
title_highlight = "full"      # whole title in accent color, not split by codepoint
```

!!! tip
    Heiti SC is available only on macOS. On other systems, and on typst.app,
    Typst falls back to a different font and the result looks different. For
    other systems, or for typst.app, use `"Noto Sans CJK SC"` in the two font
    fields. Install that font locally, or upload it to your typst.app project.

Compile the CV with the profile input:

```bash
typst compile cv.typ --input profile=zh
```

If the characters render as boxes, see [Troubleshooting → Non-Latin Characters](troubleshooting.md#non-latin-characters-showing-as-boxes).
