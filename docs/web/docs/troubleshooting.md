# Troubleshooting FAQ

## Logo Not Showing

Paths in module files are relative to the module file itself, not the project root. Use `image("../assets/logos/company.png")`.

## Font Missing

Install Roboto and Source Sans 3 (or Source Sans Pro) locally. For non-Latin languages, install the font specified in `[lang.non_latin]` (e.g. "Heiti SC" for Chinese).

## h-bar() Not Working

Make sure you import `h-bar` from the package:

```typ
#import "@preview/brilliant-cv:3.0.0": h-bar
```

The old name `hBar` has been removed in v3.

## Wrong metadata.toml Key Silently Ignored

Typst TOML parsing doesn't warn on unknown keys. Double-check key names against the [Configuration Reference](configuration.md). Common mistakes: `headerAlign` (wrong) vs `header_align` (correct).

## New Module Not Appearing

After creating a new module file, you must add its name to the `import-modules((...))` call in `cv.typ`.
