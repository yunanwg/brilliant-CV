# Troubleshooting FAQ

## Logo Not Showing

Paths in module files are relative to the module file itself, not the project root. Use `image("../assets/logos/company.png")`.

## Font Missing

Install Roboto and Source Sans 3 (or Source Sans Pro) locally. For a non-Latin profile, install each font that `[layout.fonts] regular_fonts` and `[layout.fonts] header_font` name for that profile. For example, Chinese on macOS uses "Heiti SC". "Noto Sans CJK SC" is a freely-redistributable alternative.

## Icons Render as Boxes

Contact icons use the Font Awesome desktop fonts. Download the
[Font Awesome 7 Free desktop package](https://fontawesome.com/download), then:

- In Typst Web, upload the Regular, Solid, and Brands OTF files to your project.
- For local compilation, install the same OTF files on your operating system.

After you add the fonts, compile the CV again. The package contains the icon
mappings, but it does not contain the font files.

## h-bar() Not Working

Make sure that you import `h-bar` from the package:

```typ
#import "@preview/brilliant-cv:4.1.0": h-bar
```

v3 removed the old name `hBar`. See the [Migration Guide](migration.md) for all renamed functions.

## Wrong metadata.toml Key Silently Ignored

Typst gives no warning for an unknown key in a TOML file. Make sure that each key name agrees with the [Configuration Reference](configuration.md). A common error is `headerAlign`. The correct key is `header_align`.

## New Module Not Appearing

After you create a new module file, you must add its name to the `import-modules((...))` call in `cv.typ`.

## Profile Photo Not Showing

Make sure that these two conditions are true:

1. `display_profile_photo` must be `true` in `[layout.header]` of your `metadata.toml`
2. You pass the photo as an argument in `cv.typ`. You do **not** set it in `metadata.toml`:

```typ
#show: cv.with(
  metadata,
  profile-photo: image("assets/avatar.png"),
)
```

The image path is relative to the `cv.typ` file. If your photo is in a different directory, change the path.

## Non-Latin Characters Showing as Boxes

If Chinese, Japanese, Korean, Russian, Arabic, or other non-Latin characters render as empty boxes (also called tofu), do these steps:

1. **Install the correct font on your system.** For example, Chinese on macOS uses "Heiti SC". On Linux, "Noto Sans CJK SC" is a freely-redistributable alternative.
2. **List the Latin fonts and the non-Latin fonts in `[layout.fonts] regular_fonts`.** Typst selects the font for each codepoint, so one font chain is sufficient for mixed scripts:

    ```toml
    [layout.fonts]
    regular_fonts = ["Source Sans 3", "Heiti SC"]   # Latin + CJK
    header_font = "Heiti SC"                        # heading uses CJK glyphs
    ```

3. **You can also replace the header name.** Set `[personal] display_name` to one styled string. It replaces the Latin split of first name (light) and last name (bold):

    ```toml
    [personal]
    display_name = "你的名字"
    ```

See the [Configuration Reference](configuration.md) for the complete `[layout.fonts]` and `[personal]` field list.

## Typst Version Compatibility

brilliant-CV needs **Typst 0.14.0** or newer. `typst.toml` sets this as `compiler = "0.14.0"`. If you get unexpected errors, make sure that your Typst version is recent enough:

```bash
typst --version
```

If your version is older, update to the most recent Typst release.
