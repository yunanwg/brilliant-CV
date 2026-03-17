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

## Profile-Based Overrides

If you need different `personal.info` fields per language or target role — for example, "Permis B" instead of "Driver License", or "Paris" instead of "San Francisco" — you can use **profile overrides**.

A profile is a sparse TOML file that gets [deep-merged](api-reference.md) on top of your root `metadata.toml`. Only the fields that differ need to be specified.

### Setup

**1. Create a `profiles/` directory** with one TOML file per variant:

```
profiles/
  en.toml   ← minimal (language is already "en" in root)
  fr.toml   ← overrides language + French-specific fields
```

**2. Write sparse overrides.** For example, `profiles/fr.toml`:

```toml
language = "fr"

[personal.info]
  location = "Paris, France"

  [personal.info.custom-1]
    awesomeIcon = "car"
    text = "Permis B"
```

Everything not specified (layout, fonts, email, GitHub, etc.) is inherited from root `metadata.toml`.

**3. Build with a profile:**

```bash
typst compile cv.typ --input profile=fr
```

Or set a default in `metadata.toml`:

```toml
profile = "en"
```

### How deep-merge works

The `deep-merge` function recursively combines two dictionaries:

- **No conflict** (key only in one dict) → value is kept as-is
- **Both have the key, both are dicts** → merge recursively (go deeper)
- **Both have the key, not both dicts** → profile value wins

This means `profiles/fr.toml` only overrides `personal.info.location` and `personal.info.custom-1` — all other `personal.info` fields (email, phone, github, etc.) are preserved from root.

### Tips

- **Profile ≠ language.** You can have `profiles/us.toml` and `profiles/uk.toml` both with `language = "en"` but different locations or phone numbers.
- **`--input language=xx` still works** as a final override on top of a profile, for backward compatibility.
- **Profiles are optional.** If you don't use them, everything works exactly as before.

## Skills with Inline Separators

Use `#h-bar()` to separate skill items within `cv-skill`:

```typ
#cv-skill(
  type: [Tech Stack],
  info: [Python #h-bar() SQL #h-bar() Tableau #h-bar() AWS],
)
```
