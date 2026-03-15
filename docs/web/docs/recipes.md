# Recipes

## Adding a New Module

1. Create a new file, e.g. `modules_en/volunteering.typ`
2. Add your imports and content (sections, entries, etc.)
3. In `cv.typ`, add `"volunteering"` to the `import-modules` call

## Language Override at Compile Time

```bash
typst compile cv.typ --input language=fr
```

For Chinese, Japanese, Korean, or Russian, also configure `[lang.non_latin]` in `metadata.toml` with `name` and `font`.

## Skills with Inline Separators

Use `#h-bar()` to separate skill items within `cv-skill`:

```typ
#cv-skill(
  type: [Tech Stack],
  info: [Python #h-bar() SQL #h-bar() Tableau #h-bar() AWS],
)
```
