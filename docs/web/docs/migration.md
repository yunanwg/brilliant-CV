# Migration Guide

## Migration from v3

v4 introduces a **profile-based** architecture: each CV variant lives in its own `profile_<name>/` directory with a self-contained `metadata.toml` and content modules. This solves [#142](https://github.com/yunanwg/brilliant-CV/issues/142) — you can now vary *any* field per profile (`[personal.info]`, `[layout]`, `[inject]`, the lot), not just the three localized strings v3 supported via `[lang.<code>]`.

### Design principles

- **One profile = one complete CV configuration.** Look at a single `profile_<name>/metadata.toml` and you see the full effective config for that profile — no merging, no inheritance.
- **No root `metadata.toml`.** The v4 template ships only profile directories; there is no shared/base config layer.
- **DRY is the user's job, not the framework's.** If you maintain many profiles and want to share config, you can add your own preprocessor or symlinks; the package stays simple.

### Upgrade steps

**1. Rename your module folder to a profile folder:**

```
modules_en/  →  profile_en/
```

**2. Move your `metadata.toml` into the profile folder:**

```
metadata.toml  →  profile_en/metadata.toml
```

The v3 `[lang.<code>]` structure inside `metadata.toml` continues to work — `src/` reads `metadata.lang.<lang>.header_quote` as a fallback. So you don't need to flatten the schema as part of the upgrade. (You can flatten later — set `header_quote`, `cv_footer`, `letter_footer` at the top level of each profile's `metadata.toml` and remove the `[lang.<code>]` sections.)

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
#import "@preview/brilliant-cv:4.0.0": cv
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

**6. Adding more profiles.** Copy `profile_en/` to `profile_<new>/` and edit the fields that differ. Each profile is independent — there's no DRY mechanism inside the package, by design.

See [Recipes → Switching Profiles](recipes.md#switching-profiles-at-compile-time) for compile-time examples.

### Typography is now explicit

v3 used a `language` field as a shortcut that secretly drove four typography decisions: which font got pushed onto the fallback chain, whether the section title was split into `first-N + rest`, whether `non_latin_name` replaced `first_name + last_name`, and the default date column width. v4 replaces that hidden bundle with explicit fields:

| v3 (implicit via `language=zh`) | v4 (explicit) |
|---|---|
| `non_latin_font = "Heiti SC"` | List the font in `[layout.fonts] regular_fonts` (typst's codepoint-level fallback picks per character) and set `[layout.fonts] header_font` if you want the heading in CJK type |
| section title rendered in solid accent color (not split) | `[layout.section] title_highlight = "full"` |
| `non_latin_name = "王道尔"` | `[personal] display_name = "王道尔"` |
| `_default-date-width(zh) = 4.7cm` | `[layout] date_width = "4.7cm"` |

Backward compat: v3 metadata.toml with `language = "zh"` + `non_latin_font` + `non_latin_name` continues to render. `src/` still reads those fields when `language` is one of `("zh", "ja", "ko", "ru")`. The schema marks them deprecated.

The `_is-non-latin()` whitelist and `_default-date-width()` lookup table in `src/utils/lang.typ` are removed. New non-Latin scripts (Arabic, Hebrew, Thai, Devanagari, …) work without any framework change — users just configure typography directly.

### Removed in v4 (no longer panic — fully removed)

The following parameter aliases and function aliases have **panicked since v3** and are now **removed entirely** in v4. Code still using them will fail with a generic "unknown parameter" / "unknown function" error rather than the v3 deprecation panic.

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

`cvEntry`, `cvEntryStart`, `cvEntryContinued`, `cvSection`, `cvSkill`, `cvSkillWithLevel`, `cvSkillTag`, `cvHonor`, `cvPublication`, `hBar` — use the kebab-case equivalents.

**Schema migration guards retained:** `inject_ai_prompt` and `inject_keywords` still panic with a clear upgrade message if found in `metadata.toml`. These are kept because silently ignoring an unknown metadata key would be confusing — a user who sees their ATS keywords disappear should know why.

---

## Migration from v2

v3 introduces a new directory structure, kebab-case naming, and removes several deprecated features. If you are upgrading from v2, follow these steps.

### 1. Update Imports

The package entry point is unchanged, but you should update any version-pinned imports:

```typ
// Before (v2)
#import "@preview/brilliant-cv:2.0.3": *

// After (v3)
#import "@preview/brilliant-cv:3.3.0": *
```

### 2. Parameter Renaming (now panics)

In v3, all camelCase parameter aliases **panic at compile time** instead of silently mapping to the new names. Update all call sites:

| Old (v2, camelCase) | New (v3, kebab-case) | Function |
|---------------------|----------------------|----------|
| `profilePhoto` | `profile-photo` | `cv()` |
| `myAddress` | `sender-address` | `letter()` |
| `recipientName` | `recipient-name` | `letter()` |
| `recipientAddress` | `recipient-address` | `letter()` |
| `awesomeColors` | `awesome-colors` | `cv-section`, `cv-entry`, `cv-honor`, etc. |
| `refStyle` | `ref-style` | `cv-publication` |
| `refFull` | `ref-full` | `cv-publication` |
| `keyList` | `key-list` | `cv-publication` |

### 3. Removed Function Aliases (now panic)

The old camelCase function names now panic immediately. Rename all usages:

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

The old injection keys have been removed. If your `metadata.toml` still contains them, the CV will panic:

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

- `inject_keywords` has been removed — if `injected_keywords_list` is present, keywords are injected automatically
- `inject_ai_prompt` has been removed — use `custom_ai_prompt_text` instead

### 5. Template Updates

If you are using the template, update your `cv.typ` and `letter.typ` to use the new parameter names. See the [API Reference](api-reference.md) for the current signatures.

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
