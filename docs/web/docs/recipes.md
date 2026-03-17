# Recipes

## Adding a New Module

1. Create a new file, e.g. `profile_en/volunteering.typ`
2. Add your imports and content (sections, entries, etc.)
3. In `cv.typ`, add `"volunteering"` to the `import-modules` call

## Switching Profiles at Compile Time

```bash
typst compile cv.typ --input profile=fr
```

For Chinese, Japanese, Korean, or Russian, also add `non_latin_name` and `non_latin_font` to the profile's `metadata.toml`.

## Profile-Based Overrides with Deep Merge

Each profile directory (`profile_en/`, `profile_fr/`, etc.) contains its own `metadata.toml` and content modules. The profile's `metadata.toml` is **deep-merged** on top of the root `metadata.toml`, so it only needs to contain fields that differ from the shared config.

### How it works

Your project has a shared root `metadata.toml` with layout, personal info, and other common settings. Each `profile_<name>/metadata.toml` is a sparse override:

```toml
# profile_fr/metadata.toml — only the fields that differ
language = "fr"
header_quote = "Analyste de données expérimenté..."
cv_footer = "Résumé"
letter_footer = "Lettre de motivation"

[personal.info]
  location = "Paris, France"

  # Overrides root's custom-degree with French text
  [personal.info.custom-degree]
    awesomeIcon = "graduation-cap"
    text = "Doctorat en Science des Données"
    link = "https://www.example.com"

  # New entry unique to French profile — no inheritance issue
  [personal.info.custom-car]
    awesomeIcon = "car"
    text = "Permis B"
```

Everything not specified (layout, fonts, email, GitHub, etc.) is inherited from root `metadata.toml`.

In `cv.typ`, the merge happens automatically:

```typ
#import "@preview/brilliant-cv:3.2.0": cv, deep-merge
#let profile = sys.inputs.at("profile", default: "en")
#let metadata = deep-merge(
  toml("./metadata.toml"),
  toml("profile_" + profile + "/metadata.toml"),
)
```

### How deep-merge works

The `deep-merge` function recursively combines two dictionaries:

- **No conflict** (key only in one dict) → value is kept as-is
- **Both have the key, both are dicts** → merge recursively (go deeper)
- **Both have the key, not both dicts** → profile value wins

This means `profile_fr/metadata.toml` only overrides `personal.info.location`, `personal.info.custom-degree`, and adds `personal.info.custom-car` — all other `personal.info` fields (email, phone, github, etc.) are preserved from root.

### Tips

- **Use descriptive names for custom entries** — e.g. `custom-degree`, `custom-cert`, `custom-car` instead of `custom-1`, `custom-2`. This makes inheritance behavior predictable: a French profile can define `custom-car` (new, no inheritance) while overriding `custom-degree` (replaces root's values cleanly).
- **Deep-merge inherits, not deletes** — If root has `custom-cert` and your profile doesn't mention it, it will appear in the merged result. To replace an inherited entry, override all its fields in the profile. To use completely different custom entries per profile, give each profile's entries unique descriptive names.
- **Profile ≠ language.** You can have `profile_us/` and `profile_uk/` both with `language = "en"` but different locations or phone numbers.
- **Full override is also fine.** If you prefer, a profile's `metadata.toml` can contain all fields — deep-merge still works correctly.

## Skills with Inline Separators

Use `#h-bar()` to separate skill items within `cv-skill`:

```typ
#cv-skill(
  type: [Tech Stack],
  info: [Python #h-bar() SQL #h-bar() Tableau #h-bar() AWS],
)
```

## Adding a Profile Photo

The profile photo is passed as an argument to `cv()` in your `cv.typ`, not set in `metadata.toml`:

```typ
#show: cv.with(
  metadata,
  profile-photo: image("assets/avatar.png"),
)
```

Control the shape with `profile_photo_radius` in `[layout.header]`:

- `"50%"` — circle (default)
- `"0%"` — square
- `"10%"` — rounded corners

Set `display_profile_photo = false` in `[layout.header]` to hide the photo entirely.

## Custom Contact Icon with Image

To add a custom contact entry with an image icon (instead of a Font Awesome icon):

1. Define the entry in `metadata.toml` with an `awesomeIcon` fallback:

    ```toml
    [personal.info.custom-1]
    awesomeIcon = "graduation-cap"
    text = "PhD in Data Science"
    link = "https://example.com"
    ```

2. Pass the image in `cv.typ` via the `custom-icons` parameter (the key must match `custom-1`):

    ```typ
    #show: cv.with(
      metadata,
      profile-photo: image("assets/avatar.png"),
      custom-icons: (
        "custom-1": image("assets/my-icon.png"),
      ),
    )
    ```

When a `custom-icons` entry is provided, it takes priority over the `awesomeIcon` value from TOML.

## Color Customization

### Preset Colors

Set `awesome_color` in `[layout]` to one of the built-in presets:

| Name | Hex |
|------|-----|
| `skyblue` | `#0395DE` |
| `red` | `#DC3522` |
| `nephritis` | `#27AE60` |
| `concrete` | `#95A5A6` |
| `darknight` | `#131A28` |

```toml
[layout]
awesome_color = "nephritis"
```

### Custom Hex Color

Pass any hex color string directly:

```toml
[layout]
awesome_color = "#1E90FF"
```

## Cover Letter with Signature

Create a cover letter with a signature image at the bottom:

```typ
#import "@preview/brilliant-cv:3.3.0": letter

#let metadata = toml("metadata.toml")

#show: letter.with(
  metadata,
  sender-address: "123 Main Street, City, State 12345",
  recipient-name: "ABC Company",
  recipient-address: "456 Business Ave, City, State 67890",
  date: datetime.today().display(),
  subject: "Application for Data Analyst Position",
  signature: image("assets/signature.png"),
)

Dear Hiring Manager,

// Your letter content here...

Sincerely,
```

Leave `signature` as `""` (default) to omit the signature image.

## CI/CD with GitHub Actions

A minimal workflow to compile your CV on every push:

```yaml
name: Build CV

on: [push]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Typst
        uses: typst-community/setup-typst@v4

      - name: Compile CV
        run: typst compile cv.typ cv.pdf

      - name: Upload PDF
        uses: actions/upload-artifact@v4
        with:
          name: cv
          path: cv.pdf
```

!!! tip
    If your CV uses custom fonts, add a step to install them before compiling. See the [Troubleshooting](troubleshooting.md) page for font issues.
