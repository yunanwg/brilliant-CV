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
| `metadata.toml` | Shared configuration (layout, personal info, etc.) |
| `profile_en/metadata.toml` | Profile-specific overrides (language, quotes, footers) |
| `profile_en/*.typ` | Your content modules (edit these) |
| `cv.typ` | Entry point (edit to add/remove modules) |
| `letter.typ` | Cover letter entry point |
| `assets/` | Your profile photo and logos |

!!! tip
    Don't edit the package source files under `@preview/brilliant-cv` — they are managed by the Typst package manager.

## Step 4: Configure metadata.toml

All customization goes through `metadata.toml`. This is where you set your name, colors, contact information, and layout preferences. See the [Configuration Reference](configuration.md) for the full details.

The most important keys to set first:

- `language` — the language code matching your `profile_<name>/` folder (e.g. `"en"`, `"fr"`)
- `awesome_color` — your accent color (`"skyblue"`, `"red"`, `"nephritis"`, `"concrete"`, `"darknight"`)
- `first_name` / `last_name` — your name displayed in the header
- `[personal.info]` — your contact details (email, phone, GitHub, LinkedIn, etc.)

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

## Step 7: (Optional) Set Up Profiles

If you maintain CVs in multiple languages or for different target roles, you can create **profile overrides** — sparse TOML files that only contain the fields that differ from your root `metadata.toml`. See [Recipes → Profile-Based Overrides](recipes.md#profile-based-overrides) for details.

## Step 8: Go Beyond

It is recommended to:

1. Use `git` to manage your project, as it helps trace your changes and version control your CV.
2. Use `typstyle` and `pre-commit` to help you format your CV.
3. Use `typos` to check typos in your CV if your main locale is English.
4. (Advanced) Use `LTex` in your favorite code editor to check grammars and get language suggestions.
