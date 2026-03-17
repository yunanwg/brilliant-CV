# Migration Guide

## Migration from v3

v4 adds a **`deep-merge` utility function** to the package, enabling profile-based overrides. This lets you vary any metadata field per language or target role — not just `header_quote` and footers, but also `[personal.info]`, `[layout]`, `[inject]`, and anything else ([#142](https://github.com/yunanwg/brilliant-CV/issues/142)).

### What changed?

The package now exports `deep-merge`, a recursive dictionary merge function. Your root `metadata.toml` stays as the single source of truth; optional profile files contain only the fields that differ.

### Zero-effort upgrade

v4 is **fully backward compatible**. If you don't need per-profile customization, just update the version number:

```typ
// Before
#import "@preview/brilliant-cv:3.2.0": cv

// After
#import "@preview/brilliant-cv:4.0.0": cv
```

Your existing `metadata.toml`, `modules_<lang>/` folders, `[lang.<code>]` sections, and `--input language=xx` all continue to work unchanged.

### Adopting profile overrides (optional)

To vary fields like `personal.info.location` per language:

**1. Create sparse profile files** in a `profiles/` directory:

```toml
# profiles/fr.toml — only the fields that differ
language = "fr"

[personal.info]
  location = "Paris, France"

  [personal.info.custom-1]
    awesomeIcon = "car"
    text = "Permis B"
```

**2. Update your `cv.typ` import and preamble:**

```typ
// Before (v3)
#import "@preview/brilliant-cv:3.2.0": cv

// After (v4) — add deep-merge to the import
#import "@preview/brilliant-cv:4.0.0": cv, deep-merge
#let metadata = toml("./metadata.toml")

// Profile override (new)
#let cv-profile = sys.inputs.at("profile", default: metadata.at("profile", default: none))
#let metadata = if cv-profile != none {
  deep-merge(metadata, toml("./profiles/" + cv-profile + ".toml"))
} else {
  metadata
}

// --input language=xx still works as before
#let cv-language = sys.inputs.at("language", default: none)
#let metadata = if cv-language != none {
  metadata + (language: cv-language)
} else {
  metadata
}
```

**3. Update `letter.typ`** — same preamble pattern.

**4. Build with a profile:**

```bash
typst compile cv.typ --input profile=fr
```

See [Recipes → Profile-Based Overrides](recipes.md#profile-based-overrides) for full details and examples.

---

## Migration from v2

This version introduces a new directory structure and API improvements. While we have implemented backward compatibility, we recommend updating your code to the new standard.

### 1. Update Imports

The package structure has changed. If you were importing specific files, you might need to update the paths. However, the main entry point remains the same.

### 2. Parameter Renaming

We have renamed several parameters to follow the kebab-case convention. The old camelCase parameters are still supported but deprecated.

- `cv`: `profilePhoto` → `profile-photo`
- `letter`: `myAddress` → `sender-address`, `recipientName` → `recipient-name`, `recipientAddress` → `recipient-address`
- `cv-section`, `cv-entry`: `awesomeColors` → `awesome-colors`

### 3. Template Updates

If you are using the template, we recommend updating your `cv.typ` and `letter.typ` to use the new parameter names.

---

## Migration from v1

!!! note
    The version v1 is now deprecated, due to the compliance to Typst Packages standard. However, if you want to continue to develop on the older version, please refer to the `v1-legacy` branch.

With an existing CV project using the v1 version of the template, a migration is needed, including replacing some files and some content in certain files.

1. **Delete old submodule** — Remove the `brilliant-CV` folder and `.gitmodules`. Future package management is handled directly by Typst.

2. **Migrate metadata** — Migrate all the config from `metadata.typ` by creating a new `metadata.toml`. Follow the example TOML file in the repo — it is rather straightforward to migrate.

3. **Update entry points** — For `cv.typ` and `letter.typ`, copy the new files from the repo, and adapt the modules you have in your project.

4. **Update module files** in `modules_*/`:
    1. Delete the old import `#import "../brilliant-CV/template.typ": *`, and replace it with the import statements from the new template files.
    2. Due to the Typst path handling mechanism, one cannot directly pass the path string to some functions anymore. This concerns, for example, the `logo` argument in `cv-entry`, but also `cv-publication` as well. Some parameter names were changed, but most importantly, **you should pass a function instead of a string** (i.e. `image("logo.png")` instead of `"logo.png"`). Refer to the new template files for reference.

5. **Install fonts** — You might need to install `FontAwesome 6`, `Roboto` and `Source Sans Pro` on your local system now, as new Typst package guidelines discourage including these large files.

6. **Compile** — Run `typst compile cv.typ` without passing the `font-path` flag. All should be good now — congrats!

!!! tip
    Feel free to [raise an issue](https://github.com/yunanwg/brilliant-CV/issues) for more assistance should you encounter a problem that you cannot solve on your own.
