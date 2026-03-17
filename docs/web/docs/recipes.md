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
