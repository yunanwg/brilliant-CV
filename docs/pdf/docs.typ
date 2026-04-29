/*
* Documentation of the functions used in the template, powered by tidy.
*/

#import "@preview/tidy:0.4.3"
#import "./docs-template.typ": *
#let version = toml("/typst.toml").package.version

#show: template.with(
  title: "brilliant-cv",
  subtitle: "Documentation",
  authors: ("yunanwg"),
  version: version,
)

#h(10pt)



#h(10pt)


== 1. Introduction

Brilliant CV is a Typst template for making Résume, CV or Cover Letter inspired by the famous LaTeX CV template Awesome-CV.

This document covers quick setup, component usage, common recipes, and full API reference.

== 2. Quick Start — Your First CV in 10 Minutes

=== Step 1: Bootstrap

In your local system, just working like `git clone`, bootstrap the template using this command:

```bash
typst init @preview/brilliant-cv:<version>
```

Replace the `<version>` with the latest or any releases (after 2.0.0).

=== Step 2: Install Fonts

In order to make Typst render correctly, you will have to install the required fonts #link("https://fonts.google.com/specimen/Roboto")[Roboto]
and #link("https://fonts.google.com/specimen/Source+Sans+3")[Source Sans Pro] (or Source Sans 3) in your local system.

=== Step 3: File Structure Map

After bootstrapping, your project will contain these files:

- `profile_en/metadata.toml` — complete configuration for the English profile (layout, fonts, personal info, inject, localized strings)
- `profile_en/*.typ` — your content (edit these)
- `profile_<name>/...` — other profile variants (each one is fully self-contained)
- `cv.typ` — entry point (edit to add/remove modules)
- `letter.typ` — cover letter entry point
- `assets/` — your profile photo and logos
- Don't edit: the package source files under `@preview/brilliant-cv`

=== Step 4: Configure your profile

All customization goes through each `profile_<name>/metadata.toml` — every profile is a complete, self-contained CV configuration. See Section 6 for the full configuration reference.

The most important keys to set first:

- `header_quote` / `cv_footer` / `letter_footer` — top-level localized strings shown in the header and footer of CV / cover letter pages
- `awesome_color` (under `[layout]`) — your accent color (`"skyblue"`, `"red"`, `"nephritis"`, `"concrete"`, `"darknight"`, or any hex like `"#1E90FF"`)
- `first_name` / `last_name` (under `[personal]`) — your name displayed in the header
- `[personal.info]` — your contact details (email, phone, GitHub, LinkedIn, etc.)

=== Step 5: Add Your First Entry

```typ
// Replace version with your installed version
#import "@preview/brilliant-cv:<version>": cv-section, cv-entry

#cv-section("Education")

#cv-entry(
  title: [Master of Data Science],
  society: [University of California],
  date: [2018 - 2020],
  location: [USA],
  description: list(
    [Thesis: Predicting Customer Churn using ML],
  ),
)
```

=== Step 6: Compile

```bash
typst compile cv.typ
```

=== Step 7: Go Beyond

It is recommended to:

1. Use `git` to manage your project, as it helps trace your changes and version control your CV.
2. Use `typstyle` and `pre-commit` to help you format your CV.
3. Use `typos` to check typos in your CV if your main locale is English.
4. (Advanced) Use `LTex` in your favorite code editor to check grammars and get language suggestions.


#pagebreak()
== 3. Component Gallery

These are the building blocks of your CV.

=== cv-section

```typ
#cv-section("Professional Experience")              // uses [layout.section] defaults
#cv-section("Skills", highlight: "none")            // no highlight
#cv-section("Education", highlight_letters: 5)      // first 5 chars in accent
#cv-section("教育背景", highlight: "full")          // entire title in accent (CJK convention)
```

Highlight modes are controlled globally by `[layout.section] title_highlight` (`"first-letters"` default, `"full"`, or `"none"`) and the per-call `highlight:` / `highlight_letters:` parameters override on a single section.

=== cv-entry

```typ
#cv-entry(
  title: [Data Analyst],
  society: [ABC Company],
  logo: image("assets/logos/abc.png"),
  date: [2017 - 2020],
  location: [New York, NY],
  description: list(
    [Analyzed datasets with SQL and Python],
    [Created dashboards in Tableau],
  ),
  tags: ("Python", "SQL", "Tableau"),
)
```

#tip-box[
  *Tip:* When `display_entry_society_first = true` in `metadata.toml`, the company name appears bold on top and the role appears below.
]

=== Pattern: Multiple Roles at One Company

#tip-box[
  *Pattern: Multiple Roles.* Use `cv-entry-start` + `cv-entry-continued` when someone held multiple positions at the same company.
]

```typ
#cv-entry-start(
  society: [XYZ Corporation],
  logo: image("assets/logos/xyz.png"),
  location: [San Francisco, CA],
)

#cv-entry-continued(
  title: [Director of Data Science],
  description: list([Lead a team of data scientists...]),
  tags: ("Dataiku", "Snowflake"),
)

#cv-entry-continued(
  title: [Data Scientist],
  date: [2017 - 2020],
  description: list([Analyzed large datasets...]),
)
```

#warning-box[
  *Requires* `display_entry_society_first = true` in `metadata.toml`.
]

=== cv-skill and cv-skill-with-level

```typ
#cv-skill(
  type: [Tech Stack],
  info: [Tableau #h-bar() Snowflake #h-bar() AWS],
)

#cv-skill-with-level(
  type: [Languages],
  level: 4,
  info: [English #h-bar() French #h-bar() Chinese],
)
```

Use `#h-bar()` to separate items with a vertical bar. Level is 0--5, rendered as filled/empty circles.

=== cv-skill-tag

```typ
#cv-skill(
  type: [Certifications],
  info: [
    #cv-skill-tag([AWS Certified])
    #cv-skill-tag([Google Analytics])
  ],
)
```

=== cv-honor

```typ
#cv-honor(
  date: [2022],
  title: [AWS Certified Security],
  issuer: [Amazon Web Services],
  url: "https://aws.amazon.com/certification/",
  location: [Online],
)
```

=== cv-publication

```typ
#cv-publication(
  bib: bibliography("assets/publications.bib"),
  key-list: ("smith2020", "jones2021"),
  ref-style: "ieee",
  ref-full: false,
)
```

Set `ref-full: true` to show all entries from the bib file. Set `ref-full: false` and provide `key-list` to show only selected publications.


#pagebreak()
== 4. Recipes

=== Adding a New Module

1. Create a new file, e.g. `profile_en/volunteering.typ`
2. Add your imports and content (sections, entries, etc.)
3. In `cv.typ`, add `"volunteering"` to the `import-modules` call

=== Switching Profiles at Compile Time

```bash
typst compile cv.typ --input profile=fr
```

For Chinese, Japanese, Korean, Russian, or any non-Latin profile, configure typography explicitly: list both Latin and CJK fonts in `[layout.fonts] regular_fonts` (typst's codepoint-level fallback handles mixed scripts), set `[layout.fonts] header_font` for the heading, and use `[personal] display_name` to override the Latin "first (light) + last (bold)" header treatment with a single styled string. See `template/profile_zh/metadata.toml` for a complete example.

=== Skills with Inline Separators

Use `#h-bar()` to separate skill items within `cv-skill`:

```typ
#cv-skill(
  type: [Tech Stack],
  info: [Python #h-bar() SQL #h-bar() Tableau #h-bar() AWS],
)
```


#pagebreak()
== 5. Troubleshooting FAQ

=== Logo Not Showing

Paths in module files are relative to the module file itself, not the project root. Use `image("../assets/logos/company.png")`.

=== Font Missing

Install Roboto and Source Sans 3 (or Source Sans Pro) locally. For non-Latin profiles, install the font(s) listed in your profile's `[layout.fonts]` block (e.g. "Heiti SC" for Chinese, or "Noto Sans CJK SC" as a freely-redistributable alternative).

=== h-bar() Not Working

Make sure you import `h-bar` from the package: `#import "@preview/brilliant-cv:<version>": h-bar`. The old name `hBar` has been removed in v3.

=== Wrong metadata.toml Key Silently Ignored

Typst TOML parsing doesn't warn on unknown keys. Double-check key names against the Configuration Reference (Section 6). Common mistakes: `headerAlign` (wrong) vs `header_align` (correct).

=== New Module Not Appearing

After creating a new module file, you must add its name to the `import-modules((...))` call in `cv.typ`.


#pagebreak()
== 6. Configuration Reference — `profile_<name>/metadata.toml`

Each `profile_<name>/metadata.toml` is the main configuration file for that CV variant. By changing the key-value pairs in the config file, you can set up the names, contact information, layout, and other details that will be displayed in your CV. Each profile is fully self-contained — there is no shared root configuration.

You can switch profiles at compile time via the CLI:
```bash
typst compile cv.typ --input profile=fr
```

The canonical `template/profile_en/metadata.toml` (the v4 reference profile) is reproduced below verbatim so this section never drifts from the shipped template. Each comment is also a docstring — together they describe every supported field.

#raw(read("/template/profile_en/metadata.toml"), lang: "toml", block: true)

#pagebreak()
== 7. Migrating from previous versions

This PDF reference focuses on v4. For the full v1→v2, v2→v3, and v3→v4 migration steps — including the v3→v4 panic-with-migration-message guards (`language`, `non_latin_font`, `non_latin_name`, `[lang.<code>]`, `inject_ai_prompt`, `inject_keywords`) and their v4 replacements — see the online migration guide at #link("https://github.com/yunanwg/brilliant-CV/blob/main/docs/web/docs/migration.md")[`docs/web/docs/migration.md`] in the repo.

Feel free to raise an issue for more assistance should you encounter a problem that you cannot solve on your own.

#pagebreak()
== 8. API Reference
#h(10pt)

=== Entry Point Functions

#let lib-docs = tidy.parse-module(read("/src/lib.typ"))
#tidy.show-module(
  lib-docs,
  show-outline: false,
  omit-private-definitions: true,
  omit-private-parameters: true,
)

=== CV Components

#{
  import "/src/cv.typ": cv-section, cv-entry, cv-entry-start, cv-entry-continued, cv-skill, cv-skill-with-level, cv-skill-tag, cv-honor, cv-publication, cv-metadata
  import "/src/utils/styles.typ": h-bar

  let metadata = toml("/template/profile_en/metadata.toml")

  let example-scope = (
    cv-section: cv-section,
    cv-entry: cv-entry,
    cv-entry-start: cv-entry-start,
    cv-entry-continued: cv-entry-continued,
    cv-skill: cv-skill,
    cv-skill-with-level: cv-skill-with-level,
    cv-skill-tag: cv-skill-tag,
    cv-honor: cv-honor,
    cv-publication: cv-publication,
    cv-metadata: cv-metadata,
    h-bar: h-bar,
    _metadata: metadata,
  )

  // Preamble: hidden setup code prepended to every example (state doesn't work in eval, so examples use metadata: _metadata directly)
  let example-preamble = ""

  let docs = tidy.parse-module(
    read("/src/cv.typ"),
    scope: example-scope,
    preamble: example-preamble,
  )
  tidy.show-module(
    docs,
    show-outline: false,
    omit-private-definitions: true,
    omit-private-parameters: true,
  )
}
