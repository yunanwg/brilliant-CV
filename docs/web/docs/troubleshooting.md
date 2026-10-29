# Troubleshooting FAQ

## Logo Not Showing

Paths in module files are relative to the module file itself, not the project root. Use `image("../assets/logos/company.png")`.

## Font Missing

Install Roboto and Source Sans 3 (or Source Sans Pro) locally. For a non-Latin profile, install each font that `[layout.fonts] regular_fonts` and `[layout.fonts] header_font` name for that profile. For example, Chinese on macOS uses "Heiti SC". "Noto Sans CJK SC" is a freely-redistributable alternative.

The Typst web app does not have all of these fonts. If the header name or the text renders in a different font, upload the Roboto and Source Sans 3 font files to your project, as you do for the Font Awesome files.

## Bold Text Does Not Render as Bold

If `*text*` or the bold parts of the CV render with the regular weight, the installed font is possibly a variable font. Typst cannot always select a weight from a variable font file. Remove the variable font and install the static font files, for example `SourceSans3-Bold.otf`, `SourceSans3-Regular.otf`, and the other weights. Then compile the CV again.

Related issues: [#60](https://github.com/yunanwg/brilliant-CV/issues/60), [#183](https://github.com/yunanwg/brilliant-CV/issues/183).

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
#import "@preview/brilliant-cv:4.1.1": h-bar
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

3. **You can also replace the header name.** Set `[personal] display_name` to one styled string. It replaces the Latin split of first name (light) and last name (bold). The footers and the cover letter also use it:

    ```toml
    [personal]
    display_name = "你的名字"
    ```

See the [Configuration Reference](configuration.md) for the complete `[layout.fonts]` and `[personal]` field list.

## Special Characters Cause Errors

In Typst content, `#`, `$`, `@`, `*`, `_`, and `\` have a special function. To show one of these characters as text, put a backslash before it:

```typ
#cv-skill(
  type: [Languages],
  info: [C++, C\#, F\#],
)
```

Related issue: [#86](https://github.com/yunanwg/brilliant-CV/issues/86).

## A Tag Renders as Separate Letters

An array with one item needs a comma after the item. Without the comma, Typst reads `("C++")` as one string, and the entry shows each character as a tag:

```typ
tags: ("C++",)
```

Related issue: [#91](https://github.com/yunanwg/brilliant-CV/issues/91).

## A personal.info Field Is Missing from the Header

In TOML, each key after a table header such as `[personal.info.custom-1]` goes into that table. If you write `phone` or `email` after a custom entry, the key becomes part of the custom entry, and the header does not show it. Put all plain keys of `[personal.info]` before the first `[personal.info.custom-N]` table:

```toml
[personal.info]
location = "San Francisco, CA"
phone = "+1 (415) 555-0132"
email = "john.doe@me.org"

[personal.info.custom-1]
awesomeIcon = "graduation-cap"
text = "PhD"
```

Related issue: [#131](https://github.com/yunanwg/brilliant-CV/issues/131).

## cv-entry-start Stops with a Panic

`cv-entry-start` and `cv-entry-continued` show more than one role at the same company, with the company name on top. They need `display_entry_society_first = true` in `[layout.entry]`. The starter `profile_en/professional.typ` uses them. If you set `display_entry_society_first = false`, do one of these steps:

- Set `display_entry_society_first = true` again.
- Replace each `cv-entry-start` and `cv-entry-continued` group with one `cv-entry` for each role.

Related issue: [#135](https://github.com/yunanwg/brilliant-CV/issues/135).

## A DOI Link Shows the Prefix Two Times

If a publication shows `https://doi.org/https://doi.org/...`, the `doi` field in your `.bib` file contains a full URL. Typst adds the `https://doi.org/` prefix itself. Keep only the DOI in the field:

```bibtex
doi = {10.1016/j.sbi.2025.103017},
```

Related issue: [#116](https://github.com/yunanwg/brilliant-CV/issues/116).

## A Feature Is Not Available

Some requests come back often. [Design Scope](scope.md) shows what the configuration already does, and what the package does not add.

## Typst Version Compatibility

brilliant-CV needs **Typst 0.14.0** or newer. `typst.toml` sets this as `compiler = "0.14.0"`. If you get unexpected errors, make sure that your Typst version is recent enough:

```bash
typst --version
```

If your version is older, update to the most recent Typst release.
