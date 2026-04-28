# Troubleshooting FAQ

## Logo Not Showing

Paths in module files are relative to the module file itself, not the project root. Use `image("../assets/logos/company.png")`.

## Font Missing

Install Roboto and Source Sans 3 (or Source Sans Pro) locally. For non-Latin languages, install the font specified in `[lang.non_latin]` (e.g. "Heiti SC" for Chinese).

## h-bar() Not Working

Make sure you import `h-bar` from the package:

```typ
#import "@preview/brilliant-cv:4.0.0": h-bar
```

The old name `hBar` has been removed in v3. See the [Migration Guide](migration.md) for all renamed functions.

## Wrong metadata.toml Key Silently Ignored

Typst TOML parsing doesn't warn on unknown keys. Double-check key names against the [Configuration Reference](configuration.md). Common mistakes: `headerAlign` (wrong) vs `header_align` (correct).

## New Module Not Appearing

After creating a new module file, you must add its name to the `import-modules((...))` call in `cv.typ`.

## Profile Photo Not Showing

Check two things:

1. `display_profile_photo` must be `true` in `[layout.header]` of your `metadata.toml`
2. The photo is passed as an argument in `cv.typ`, **not** set in `metadata.toml`:

```typ
#show: cv.with(
  metadata,
  profile-photo: image("assets/avatar.png"),
)
```

The image path is relative to the `cv.typ` file. If your photo is in a different directory, adjust the path accordingly.

## Non-Latin Characters Showing as Boxes

If Chinese, Japanese, Korean, or Russian characters render as empty boxes or tofu:

1. Install the appropriate font on your system (e.g. "Heiti SC" for Chinese)
2. Configure the font in `metadata.toml`:

```toml
[lang.non_latin]
name = "你的名字"
font = "Heiti SC"
```

You can also override fonts globally using the `[layout.fonts]` section — see the [Configuration Reference](configuration.md#layoutfonts).

## Typst Version Compatibility

brilliant-CV requires **Typst 0.14.0** or newer (set in `typst.toml` as `compiler = "0.14.0"`). If you encounter unexpected errors, check your Typst version:

```bash
typst --version
```

Update to the latest Typst release if you're on an older version.
