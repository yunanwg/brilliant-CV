# Migration Guide

## Migration from v3

v4 has a **profile-based** architecture. Each CV variant is in its own `profile_<name>/` directory, with a self-contained `metadata.toml` and its content modules. This corrects [#142](https://github.com/yunanwg/brilliant-CV/issues/142). You can now change *any* field for each profile, which includes `[personal.info]`, `[layout]`, and `[inject]`. v3 supported only the three localized strings in `[lang.<code>]`.

### Design principles

- **One profile is one complete CV configuration.** A single `profile_<name>/metadata.toml` shows the full effective configuration for that profile. There is no merge and no inheritance.
- **No root `metadata.toml`.** The v4 template contains only profile directories. There is no shared base configuration layer.
- **DRY is the work of the user, not of the package.** To share configuration between many profiles, you can add your own preprocessor or symlinks. The package stays simple.

### Upgrade steps

**1. Rename your module directory to a profile directory:**

```
modules_en/  →  profile_en/
```

**2. Move your `metadata.toml` into the profile directory and flatten the schema:**

```
metadata.toml  →  profile_en/metadata.toml
```

You must also flatten the v3 `[lang.<code>]` structure to top-level fields. When v4 finds a v3-only schema field, it panics. This is the same behavior as the v2 to v3 `inject_*` migration guards. For the exact field mapping, see "Schema migration guards".

**3. Update your `cv.typ`:**

```typ
// Before (v3)
#import "@preview/brilliant-cv:3.3.0": cv
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

// After (v4) — profile-based, no merge
// release-current-version
#import "@preview/brilliant-cv:4.1.0": cv
#let profile = sys.inputs.at("profile", default: "en")
#let metadata = toml("profile_" + profile + "/metadata.toml")
#let import-modules(modules) = {
  for module in modules {
    include { "profile_" + profile + "/" + module + ".typ" }
  }
}
```

**4. Update `letter.typ`** — same preamble pattern.

**5. Update CLI commands:**

```bash
typst compile cv.typ --input profile=fr
```

**6. Add more profiles.** Copy `profile_en/` to `profile_<new>/`. Then edit the fields that are different. Each profile is independent. The package has no DRY mechanism, and this is intentional.

See [Recipes → Switching Profiles](recipes.md#switching-profiles-at-compile-time) for compile-time examples.

### Schema migration guards (panic on v3 fields)

v4 uses the same pattern as the v2 to v3 migration of `inject_ai_prompt` and `inject_keywords`. When the package finds a removed v3 schema field at compile time, it **panics with a migration message**. It does not fall back silently. A silent fallback is an anti-pattern, because it hides a change of behavior.

The guarded fields and their replacements:

| v3 field | Panic? | v4 replacement |
|---|---|---|
| `language` | ✅ | Set typography explicitly: `[layout.fonts] regular_fonts`, `[layout.fonts] header_font`, `[layout.section] title_highlight`, `[personal] display_name`, `[layout] date_width` |
| `non_latin_font` | ✅ | List both fonts in `[layout.fonts] regular_fonts = ["Source Sans 3", "Heiti SC"]` and set `[layout.fonts] header_font`. Typst selects the font for each codepoint, so mixed scripts work. A test with `pdffonts` shows the same embedded subsets as the v3 trigger. |
| `non_latin_name` | ✅ | `[personal] display_name`. It replaces the Latin split of first name and last name with one styled string. |
| `[lang.<code>]` table | ✅ | Set `header_quote`, `cv_footer`, `letter_footer` as top-level fields in `profile_<name>/metadata.toml` |
| `[lang.non_latin]` table | ✅ (the `[lang.*]` panic in the previous row covers it) | Use `[personal] display_name` and `[layout.fonts]` |

#### v3 (`language=zh`) → v4 example

**Before:**

```toml
language = "zh"
non_latin_font = "Heiti SC"
non_latin_name = "王道尔"

[lang.zh]
header_quote = "具有丰富经验的数据分析师，随时可入职"
cv_footer = "简历"
letter_footer = "申请信"
```

**After:**

```toml
header_quote = "具有丰富经验的数据分析师，随时可入职"
cv_footer = "简历"
letter_footer = "申请信"

[layout]
date_width = "4.7cm"

[layout.fonts]
regular_fonts = ["Source Sans 3", "Heiti SC"]
header_font = "Heiti SC"

[layout.section]
title_highlight = "full"

[personal]
display_name = "王道尔"
```

v4 removes the file `src/utils/lang.typ`, with its `_is-non-latin()` whitelist and its `_default-date-width()` lookup table. A new non-Latin script (Arabic, Hebrew, Thai, Devanagari, and more) no longer needs a change to the package. Users configure the typography directly.

### Why panic instead of silent fallback?

The package has three patterns for backward compatibility. For schema changes, v4 uses **panic with a migration message**:

| Pattern | When used | Example |
|---|---|---|
| **Panic with migration message** | Removed metadata schema fields | `inject_ai_prompt`, v3 `language` / `non_latin_*` / `[lang.*]` |
| **Fully removed** | Renamed function/parameter aliases | `cvEntry`, `profilePhoto`, `awesomeColors` (typst gives a generic "unknown parameter" error) |
| **Silent fallback** | ❌ Not used in v4. v3 metadata fields used it for a short time. v4 removed it, because a hidden change of behavior broke the "explicit > implicit" design. |

### Removed in v4 (no longer panic — fully removed)

These parameter aliases and function aliases **panicked in v3**. v4 **removes them completely**. Code that still uses them fails with a generic "unknown parameter" or "unknown function" error, not with the v3 deprecation panic.

**Parameter aliases (now removed):**

| Removed name | Use instead |
|---|---|
| `profilePhoto` (in `cv()`) | `profile-photo` |
| `myAddress` (in `letter()`) | `sender-address` |
| `recipientName` (in `letter()`) | `recipient-name` |
| `recipientAddress` (in `letter()`) | `recipient-address` |
| `awesomeColors` (in entry/section/honor) | `awesome-colors` |
| `refStyle` (in `cv-publication`) | `ref-style` |
| `refFull` (in `cv-publication`) | `ref-full` |
| `keyList` (in `cv-publication`) | `key-list` |

**Function aliases (now removed):**

`cvEntry`, `cvEntryStart`, `cvEntryContinued`, `cvSection`, `cvSkill`, `cvSkillWithLevel`, `cvSkillTag`, `cvHonor`, `cvPublication`, and `hBar`. Use the kebab-case names.

**Schema migration guards kept:** if `metadata.toml` contains `inject_ai_prompt` or `inject_keywords`, the package still panics with a clear upgrade message. A silent ignore of an unknown metadata key is confusing. A user whose ATS keywords disappear must know the cause.

### Supported root exports in v4

The supported package-root API consists of `cv`, `letter`, `cv-section`, `cv-entry`, `cv-entry-start`, `cv-entry-continued`, `cv-skill`, `cv-skill-with-level`, `cv-skill-tag`, `cv-honor`, `cv-publication`, `h-bar`, and `overwrite-fonts`.

`overwrite-fonts` stays in the API for v4 compatibility, because older wildcard imports made it reachable. In a new template, configure `[layout.fonts]` and let `cv()` or `letter()` resolve the fonts. A new decision about this helper belongs in v5.

Older releases also made dependency symbols available through wildcard imports, such as the `fa-*` icons and the internal state. These symbols were never documented compatibility commitments, and the package no longer re-exports them. Import the icons from Font Awesome directly:

```typ
#import "@preview/fontawesome:0.6.2": fa-github
```

---

## Migration from v2

v3 has a new directory structure and kebab-case names. It also removes several deprecated features. If you upgrade from v2, do these steps.

### 1. Update Imports

The package entry point does not change. Update each version-pinned import:

```typ
// Before (v2)
#import "@preview/brilliant-cv:2.3.0": *

// After (v3)
#import "@preview/brilliant-cv:3.3.0": *
```

### 2. Parameter Renaming (now panics)

In v3, all camelCase parameter aliases **panic at compile time**. They do not map silently to the new names. Update every call site:

| Old (v2, camelCase) | New (v3, kebab-case) | Function |
|---------------------|----------------------|----------|
| `profilePhoto` | `profile-photo` | `cv()` |
| `myAddress` | `sender-address` | `letter()` |
| `recipientName` | `recipient-name` | `letter()` |
| `recipientAddress` | `recipient-address` | `letter()` |
| `awesomeColors` | `awesome-colors` | `cv-section`, `cv-entry`, `cv-honor`, and more |
| `refStyle` | `ref-style` | `cv-publication` |
| `refFull` | `ref-full` | `cv-publication` |
| `keyList` | `key-list` | `cv-publication` |

### 3. Removed Function Aliases (now panic)

The old camelCase function names now panic immediately. Rename every use:

| Old (v2) | New (v3) |
|----------|----------|
| `cvEntry` | `cv-entry` |
| `cvEntryStart` | `cv-entry-start` |
| `cvEntryContinued` | `cv-entry-continued` |
| `cvSection` | `cv-section` |
| `cvSkill` | `cv-skill` |
| `cvSkillWithLevel` | `cv-skill-with-level` |
| `cvSkillTag` | `cv-skill-tag` |
| `cvHonor` | `cv-honor` |
| `cvPublication` | `cv-publication` |
| `hBar` | `h-bar` |

### 4. Removed `[inject]` Keys (now panic)

v3 removes the old injection keys. If your `metadata.toml` still contains them, the CV panics:

```toml
# Before (v2) — these now cause panics
[inject]
inject_ai_prompt = true
inject_keywords = true
injected_keywords_list = ["Python", "SQL"]

# After (v3) — just use the list directly; remove the boolean flags
[inject]
injected_keywords_list = ["Python", "SQL"]
# custom_ai_prompt_text = "Optional custom prompt"
```

- `inject_keywords` is removed. If `injected_keywords_list` is present, the package injects the keywords automatically.
- `inject_ai_prompt` is removed. Use `custom_ai_prompt_text`.

### 5. Template Updates

If you use the template, update `cv.typ` and `letter.typ` with the new parameter names. For the current signatures, see the [API Reference](api-reference.md).

---

## Migration from v1

!!! note
    Version v1 is deprecated, because the package now obeys the Typst Packages standard. To continue work on the older version, use the `v1-legacy` branch.

An existing CV project that uses v1 needs a migration. You must replace some files, and some content in other files.

1. **Remove the old submodule** — Remove the `brilliant-CV` directory and `.gitmodules`. Typst now does the package management.

2. **Migrate the metadata** — Create a new `metadata.toml` and move all the configuration from `metadata.typ` into it. Use the example TOML file in the repository as a model.

3. **Update the entry points** — Copy the new `cv.typ` and `letter.typ` from the repository. Then adapt them to the modules in your project.

4. **Update module files** in `modules_*/`:
    1. Remove the old import `#import "../brilliant-CV/template.typ": *`. Replace it with the import statements from the new template files.
    2. Typst changed its path handling, so some functions no longer accept a path string. This applies to the `logo` argument in `cv-entry` and to `cv-publication`. Some parameter names also changed. **Pass a function, not a string.** For example, use `image("logo.png")` in place of `"logo.png"`. For more information, see the new template files.

5. **Install the fonts** — You can need `FontAwesome 6`, `Roboto`, and `Source Sans Pro` on your local system. The new Typst package guidelines are against the inclusion of these large files in a package.

6. **Compile** — Run `typst compile cv.typ`. Do not use the `font-path` flag. The migration is then complete.

!!! tip
    If you have a problem that you cannot solve, [raise an issue](https://github.com/yunanwg/brilliant-CV/issues).
