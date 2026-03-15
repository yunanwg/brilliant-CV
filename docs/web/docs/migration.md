# Migration Guide

## Migration from v3

v4 replaces the language-based switching system with a **profile-based** architecture. Each profile is a self-contained folder with its own `metadata.toml` and module files, enabling full customization per variant — not just language-specific quotes, but also different personal info, layout, and keywords per target role or industry.

### Why this change?

In v3, all CV variants share a single `metadata.toml`. The `[lang.<code>]` sections only allow varying `header_quote`, `cv_footer`, and `letter_footer` per language. Fields like `[personal.info]`, `[layout]`, and `[inject]` are global and cannot differ between languages or target roles ([#142](https://github.com/yunanwg/brilliant-CV/issues/142)).

The new profile system makes each variant fully independent: a `profile_en/` folder for your English CV, a `profile_fr/` for French, a `profile_swe/` tailored for software engineering roles — each with its own metadata, personal info, and content modules.

### Upgrade paths

#### Option A: Zero-effort upgrade (keep v3 structure)

The v4 package is **fully backward compatible** with the v3 metadata format. If you don't need per-profile customization, just update the version number:

```typ
// Before
#import "@preview/brilliant-cv:3.2.0": cv

// After
#import "@preview/brilliant-cv:4.0.0": cv
```

Your existing `metadata.toml` with `[lang.<code>]` sections, `modules_<lang>/` folders, and `--input language=xx` CLI pattern will continue to work as before.

#### Option B: Migrate to profile-based structure

Follow these steps to adopt the new architecture:

**1. Rename module folders**

```
modules_en/  →  profile_en/
modules_fr/  →  profile_fr/
```

**2. Create per-profile `metadata.toml`**

Copy your root `metadata.toml` into each profile folder and make these changes:

```toml
# Before (v3 root metadata.toml)
language = "en"

[lang.en]
    header_quote = "Experienced Data Analyst..."
    cv_footer = "Curriculum vitae"
    letter_footer = "Cover letter"

[lang.non_latin]
    name = "王道尔"
    font = "Heiti SC"

# After (profile_en/metadata.toml) — flat, no [lang] nesting
language = "en"
header_quote = "Experienced Data Analyst..."
cv_footer = "Curriculum vitae"
letter_footer = "Cover letter"
```

For non-Latin profiles (zh, ja, ko, ru), move the non-Latin settings to top-level:

```toml
# profile_zh/metadata.toml
language = "zh"
header_quote = "具有丰富经验的数据分析师，随时可入职"
cv_footer = "简历"
letter_footer = "申请信"
non_latin_name = "王道尔"
non_latin_font = "Heiti SC"
```

Remove the `[lang.*]` sections entirely from each profile's `metadata.toml`. You can now customize `[personal]`, `[layout]`, `[inject]`, and all other sections independently per profile.

**3. Update `cv.typ`**

```typ
// Before (v3)
#let metadata = toml("./metadata.toml")
#let cv-language = sys.inputs.at("language", default: none)
#let metadata = if cv-language != none {
  metadata + (language: cv-language)
} else {
  metadata
}
#let import-modules(modules, lang: metadata.language) = {
  for module in modules {
    include { "modules_" + lang + "/" + module + ".typ" }
  }
}

// After (v4)
#let profile = sys.inputs.at("profile", default: "en")
#let metadata = toml("profile_" + profile + "/metadata.toml")
#let import-modules(modules) = {
  for module in modules {
    include { "profile_" + profile + "/" + module + ".typ" }
  }
}
```

**4. Update `letter.typ`** — same pattern as `cv.typ`.

**5. Update CLI commands**

```bash
# Before
typst compile cv.typ --input language=fr

# After
typst compile cv.typ --input profile=fr
```

**6. Clean up** — delete the root `metadata.toml` (each profile folder now has its own).

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
