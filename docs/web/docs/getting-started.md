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

## Step 6: Compile

```bash
typst compile cv.typ
```

## Step 7: (Optional) Add More Profiles

If you maintain CVs in multiple languages or for different target roles, copy `profile_en/` to `profile_<name>/` and edit the fields that differ. Each profile is independent — there is no shared root config to coordinate. See [Recipes → Adding a New Profile](recipes.md#adding-a-new-profile) for details.

## Step 8: Go Beyond

It is recommended to:

1. Use `git` to manage your project, as it helps trace your changes and version control your CV.
2. Use `typstyle` and `pre-commit` to help you format your CV.
3. Use `typos` to check typos in your CV if your main locale is English.
4. (Advanced) Use `LTex` in your favorite code editor to check grammars and get language suggestions.
