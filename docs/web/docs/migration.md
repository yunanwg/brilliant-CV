# Migration Guide

## Migration from v2

v3 introduces a new directory structure, kebab-case naming, and removes several deprecated features. If you are upgrading from v2, follow these steps.

### 1. Update Imports

The package entry point is unchanged, but you should update any version-pinned imports:

```typ
// Before (v2)
#import "@preview/brilliant-cv:2.0.3": *

// After (v3)
#import "@preview/brilliant-cv:3.2.0": *
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
