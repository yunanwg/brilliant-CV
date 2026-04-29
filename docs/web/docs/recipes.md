# Recipes

## Adding a New Module

1. Create a new file, e.g. `profile_en/volunteering.typ`
2. Add your imports and content (sections, entries, etc.)
3. In `cv.typ`, add `"volunteering"` to the `import-modules` call

## Switching Profiles at Compile Time

```bash
typst compile cv.typ --input profile=fr
```

The `profile` input picks which `profile_<name>/` directory to load. For non-Latin scripts (Chinese, Japanese, Korean, Russian, Arabic, …), configure typography explicitly in `[layout.fonts]` (font fallback chain), `[layout.section]` (title highlighting), and `[personal] display_name`. See `template/profile_zh/metadata.toml` for a complete example.

## Adding a New Profile

Each profile is **self-contained** — one `profile_<name>/metadata.toml` holds the complete CV configuration for that variant. To add a new profile (e.g. a Swedish CV):

1. Copy an existing profile directory:
    ```bash
    cp -r template/profile_en template/profile_swe
    ```
2. Edit `profile_swe/metadata.toml` — change `header_quote`, `cv_footer`, `letter_footer`, and any other fields that differ from English.
3. Edit the `.typ` modules under `profile_swe/` for Swedish content.
4. Compile with `typst compile cv.typ --input profile=swe`.

There is no shared root metadata or merge mechanism in v4. **Profile = a complete CV config**; copy-paste is the way to start a new one.

### Profile ≠ language

The profile name is just a directory suffix — it doesn't carry semantic meaning to the package. You can have `profile_us/` and `profile_uk/` (both English text, different locations / phone numbers / layouts) sitting next to `profile_zh/` (Chinese with Heiti SC); each profile's `metadata.toml` is independently complete. Pick whatever directory names make sense for your variants.

### Sharing config across profiles

If you maintain many profiles and want to share fields (GitHub username, layout colors, etc.), the package itself does not provide a merge mechanism. Common user-side options:

- **A small Python/shell preprocessor** that reads a canonical base + per-profile overrides and writes the profile `metadata.toml` files at build time.
- **`typstyle`-friendly hand-edits** — for 2-3 profiles, manual sync is usually fine.
- **Symlinks or `git rerere`** to keep selected fields in sync.

The framework keeps "one profile = one file" so your tooling stays free.

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
#import "@preview/brilliant-cv:4.0.0": letter

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
