# Getting Started — Your First CV in 10 Minutes

## Step 1: Bootstrap

In your local system, bootstrap the template using this command:

```bash
typst init @preview/brilliant-cv
```

Replace the version with the latest or any release (after 2.0.0) if needed:

```bash
typst init @preview/brilliant-cv:4.0.0
```

## Step 2: Install Fonts

In order to make Typst render correctly, you will have to install the required fonts:

- [Roboto](https://fonts.google.com/specimen/Roboto)
- [Source Sans 3](https://fonts.google.com/specimen/Source+Sans+3) (or Source Sans Pro)

## Step 3: File Structure Map

After bootstrapping, your project will contain these files:

| File / Directory | Purpose |
|-----------------|---------|
| `cv.typ` | Entry point (edit to add/remove modules) |
| `letter.typ` | Cover letter entry point |
| `profile_en/metadata.toml` | Complete configuration for the English profile |
| `profile_en/*.typ` | Your English content modules (edit these) |
| `profile_<name>/...` | Other profile variants (fr, de, it, zh provided as examples) |
| `assets/` | Your profile photo and logos |

!!! tip
    Don't edit the package source files under `@preview/brilliant-cv` — they are managed by the Typst package manager.

## Step 4: Configure profile_en/metadata.toml

All customization for the English profile goes through `profile_en/metadata.toml` — it is a **complete, self-contained CV configuration**. See the [Configuration Reference](configuration.md) for the full set of fields.

The most important keys to set first:

- `awesome_color` — your accent color (`"skyblue"`, `"red"`, `"nephritis"`, `"concrete"`, `"darknight"`)
- `first_name` / `last_name` — your name displayed in the header
- `[personal.info]` — your contact details (email, phone, GitHub, LinkedIn, etc.)
- `header_quote` — italic tagline below your name
- `cv_footer` / `letter_footer` — text shown in the footer

## Step 5: Add Your First Entry

Open `profile_en/education.typ` and replace its contents with:

```typ
#import "@preview/brilliant-cv:4.0.0": cv-section, cv-entry

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

Each profile module file (`education.typ`, `professional.typ`, `projects.typ`, `certificates.typ`, `publications.typ`, `skills.typ`) imports from `@preview/brilliant-cv` and emits `cv-*` calls — `cv.typ` includes them in order. Add new sections by creating a new module file under `profile_en/` and adding its name to the `import-modules((...))` call in `cv.typ`.

## Step 6: Compile

```bash
typst compile cv.typ
```

## Step 7: (Optional) Add More Profiles

If you maintain CVs in multiple languages or for different target roles, copy `profile_en/` to `profile_<name>/` and edit the fields that differ. Each profile is independent — there is no shared root config to coordinate. See [Recipes → Adding a New Profile](recipes.md#adding-a-new-profile) for details.

## Step 8: Go Beyond

It is recommended to:

1. Use `git` to manage your project — track changes and tag releases of your CV (`git tag cv-v1`, `git tag cv-v2`).
2. Use [`typstyle`](https://github.com/typstyle-rs/typstyle) and `pre-commit` to keep your `.typ` files consistently formatted.
3. Use [`typos`](https://github.com/crate-ci/typos) to catch spelling mistakes if your CV is in English.
4. Wire up CI to compile your CV on every push — see [Recipes → CI/CD with GitHub Actions](recipes.md#cicd-with-github-actions).
