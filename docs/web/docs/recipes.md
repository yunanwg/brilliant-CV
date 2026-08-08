# Recipes

## Adding a New Module

1. Create a new file, for example `profile_en/volunteering.typ`
2. Add your imports and your content (sections, entries, and more)
3. In `cv.typ`, add `"volunteering"` to the `import-modules` call

## Switching Profiles at Compile Time

```bash
typst compile cv.typ --input profile=fr
```

The `profile` input selects the `profile_<name>/` directory to load. For a non-Latin script (Chinese, Japanese, Korean, Russian, Arabic, and more), configure the typography explicitly. Set the font fallback chain in `[layout.fonts]`, the title highlight in `[layout.section]`, and the name in `[personal] display_name`. For a complete example, see `template/profile_zh/metadata.toml`.

## Adding a New Profile

Each profile is **self-contained**. One `profile_<name>/metadata.toml` holds the complete CV configuration for that variant. To add a new profile, for example a Swedish CV, do these steps:

1. Copy an existing profile directory:
    ```bash
    cp -r template/profile_en template/profile_swe
    ```
2. Edit `profile_swe/metadata.toml`. Change `header_quote`, `cv_footer`, `letter_footer`, and each other field that is different from English.
3. Edit the `.typ` modules under `profile_swe/` for Swedish content.
4. Compile with `typst compile cv.typ --input profile=swe`.

v4 has no shared root metadata and no merge mechanism. **One profile is one complete CV configuration.** To start a new profile, copy an existing one.

### Profile ≠ language

The profile name is only a directory suffix. It has no meaning for the package. For example, you can keep `profile_us/` and `profile_uk/` next to `profile_zh/`. The first two hold English text with different locations, phone numbers, and layouts. The third holds Chinese text with Heiti SC.

The `metadata.toml` of each profile is complete on its own. Select the directory names that are correct for your variants.

### Sharing configuration across profiles

The package has no merge mechanism for shared fields, such as a GitHub username or the layout colors. If you keep many profiles, these options are available to you:

- **A small Python or shell preprocessor.** It reads a canonical base and the overrides of each profile, then writes the profile `metadata.toml` files at build time.
- **`typstyle`-friendly manual edits.** For 2 or 3 profiles, manual synchronization is usually sufficient.
- **Symlinks or `git rerere`** to keep the selected fields synchronized.

The package keeps one profile in one file, so you can select your own tools.

## Skills with Inline Separators

Use `#h-bar()` to separate the skill items in `cv-skill`:

```typ
#cv-skill(
  type: [Tech Stack],
  info: [Python #h-bar() SQL #h-bar() Tableau #h-bar() AWS],
)
```

## Verification Links and Richer Certificate Metadata

`cv-honor` is compact. It has `date`, `title`, `issuer`, `url`, and `location`, but it has no free-form description field. Select the component that shows the data you need.

**For a clickable verification link only**, pass the verification URL as `url`. The title becomes a link. Put short status text in `location`:

```typ
#cv-honor(
  date: [2025],
  title: [AWS Certified Solutions Architect],
  issuer: [Amazon Web Services],
  url: "https://www.credly.com/badges/<your-badge-id>",
  location: [Verified],
)
```

**For a credential ID, an expiry date, or more than one link**, use `cv-entry`. Its `description` field accepts any content. This component uses more space on the page, but it gives you full control of the format:

```typ
#cv-entry(
  title: [AWS Certified Solutions Architect],
  society: [Amazon Web Services],
  date: [2025 -- 2028],
  location: [Verified],
  description: list(
    [Credential ID: ABC-123-XYZ],
    [#link("https://verify.example.com")[Verify online]],
  ),
)
```

You can use the two components together in one `Certificates` section. For each entry, select `cv-honor` for the compact one-line layout, or `cv-entry` for the larger description block.

## Adding a Profile Photo

You pass the profile photo as an argument to `cv()` in your `cv.typ`. You do not set it in `metadata.toml`:

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

To hide the photo, set `display_profile_photo = false` in `[layout.header]`.

## Custom Contact Icon with Image

To add a custom contact entry with an image icon in place of a Font Awesome icon, do these steps:

1. Define the entry in `metadata.toml` with an `awesomeIcon` fallback:

    ```toml
    [personal.info.custom-1]
    awesomeIcon = "graduation-cap"
    text = "PhD in Data Science"
    link = "https://example.com"
    ```

2. Pass the image in `cv.typ` with the `custom-icons` parameter. The key must agree with `custom-1`:

    ```typ
    #show: cv.with(
      metadata,
      profile-photo: image("assets/avatar.png"),
      custom-icons: (
        "custom-1": image("assets/my-icon.png"),
      ),
    )
    ```

If you give a `custom-icons` entry, it has priority over the `awesomeIcon` value from the TOML file.

## Custom Header Info

The default header makes a linked contact item from each `[personal.info]` entry. It adds the icons and puts `h-bar()` between the items automatically. You can also control the separators, the line breaks, and the accent color of each span. To do this, pass your own content in `header-info`:

```typ
#import "@preview/brilliant-cv:4.1.0": cv, h-bar

#let info = metadata.personal.info

#show: cv.with(
  metadata,
  profile-photo: image("assets/avatar.png"),
  header-info: [
    #link("mailto:" + info.email)[#info.email]
    #h-bar()
    #text(fill: black)[Berlin, Germany]
    #linebreak()
    #text(fill: rgb("#2E7D32"))[Available for remote work]
  ],
)
```

Your content inherits the default font size and accent color of the header info. To override these defaults, style each span explicitly. Your content also replaces the automatic rendering of `[personal.info]`. Add the icons and the links that you want directly in the content. `custom-icons` applies only to the default `auto` renderer.

You can use a function to make your template clearer. Call the function first, then pass its result. The API accepts content, not a renderer callback:

```typ
#let render-info(info) = [#info.email #h-bar() #info.location]

#show: cv.with(
  metadata,
  header-info: render-info(metadata.personal.info),
)
```

To remove the contact row, pass `header-info: none`. The name, the optional quote, the photo, and the rest of the layout do not change.

## Color Customization

### Preset Colors

Set `awesome_color` in `[layout]` to one of these presets:

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

You can also set any hex color string directly:

```toml
[layout]
awesome_color = "#1E90FF"
```

## Cover Letter with Signature

Create a cover letter with a signature image at the bottom:

```typ
#import "@preview/brilliant-cv:4.1.0": letter

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

To omit the signature image, leave `signature` as `""`. This is the default value.

## CI/CD with GitHub Actions

This is a minimal workflow that compiles your CV on each push:

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
    If your CV uses custom fonts, add a step that installs them before the compile step. For font problems, see the [Troubleshooting](troubleshooting.md) page.
