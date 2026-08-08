# Component Gallery

These are the building blocks of your CV. Each example has the rendered output after it. The PNGs are the same files that the [test suite](https://github.com/yunanwg/brilliant-CV/tree/main/tests/components) uses as visual-regression baselines, so this page shows exactly what the package produces. For the full parameter details, see the [API Reference](api-reference.md).

## Component context in v4

CV components usually read the layout configuration from the metadata context. The enclosing `#show: cv.with(metadata, ...)` rule installs this context. Typst state is contextual and positional, so the component calls must stay in the `cv()` document body, as the starter does. For standalone composition or for tests, pass `metadata: metadata` explicitly. This alternative is supported, and each applicable component signature documents it.

v4 keeps this ambient behavior for compatibility. A component with no explicit metadata and no surrounding `cv()` context fails with a clear message at the call site. The state object and the underscore-prefixed helpers are implementation details. A replacement context design, or factory design, belongs in v5 with a migration path.

The supported package-root API is `cv`, `letter`, the nine documented `cv-*` components, `h-bar`, and the compatibility helper `overwrite-fonts`. A new template must configure `[layout.fonts]` and must not call `overwrite-fonts` directly. The package does not re-export dependency symbols such as the `fa-*` icons. Import them from `fontawesome` directly.

## Entry Point Functions

### `cv()`

```typ
#show: cv.with(
  metadata,
  profile-photo: image("assets/avatar.png"),
)
```

The `cv()` function is the main entry point. It operates the schema-migration guards, which panic on v3 fields. It also sets the page layout, applies the fonts, renders the header, and puts `_cv-footer` on every page. All your CV modules go in its body.

By default, `header-info: auto` renders the entries from `metadata.personal.info`. To replace that row, pass your own content. The name, the photo, and the header layout do not change:

```typ
#import "@preview/brilliant-cv:4.1.0": cv, h-bar

#let info = metadata.personal.info

#show: cv.with(
  metadata,
  header-info: [
    #link("mailto:" + info.email)[#info.email]
    #h-bar()
    #text(fill: black)[Berlin, Germany]
    #linebreak()
    #text(fill: rgb("#2E7D32"))[Available for remote work]
  ],
)
```

![custom header info](assets/components/cv-header-info-custom.png)

Your content inherits the normal typography and accent color of the header info. Nested `text(...)` rules can override each span. To remove the contact row, use `header-info: none`. The [Custom Header Info](recipes.md#custom-header-info) recipe describes the interaction with the metadata and with the custom icons.

### `letter()`

```typ
#show: letter.with(
  metadata,
  sender-address: "123 Main St, City, State 12345",
  recipient-name: "ABC Company",
  recipient-address: "456 Business Ave, City, State 67890",
  subject: "Application for Data Analyst Position",
  signature: image("assets/signature.png"),
)
```

`letter()` is equivalent to `cv()` for cover-letter pages. It uses formal letter margins and a 12pt body. The default value of `sender-address` is `auto`, which reads `metadata.personal.address`. If that field is not set, the value becomes `"Your Address Here"`. To remove the smallcaps from the addresses, use `address-style: "normal"`.

---

## CV Components

### `cv-section`

```typ
#cv-section("Education")
```

![cv-section first-letters mode](assets/components/cv-section-first-letters.png)

The default value `[layout.section] title_highlight = "first-letters"` highlights the first 3 characters in the accent color. This is the Latin convention. To override it in one call, use `highlight:` (`"first-letters"`, `"full"`, or `"none"`) and `highlight-letters:` (an integer).

```typ
#cv-section("教育背景", highlight: "full")
```

![cv-section full mode](assets/components/cv-section-full.png)

The `"full"` mode colors the complete title. This is the CJK convention, and `profile_zh` uses it.

```typ
#cv-section("Education", highlight: "none")
```

![cv-section none mode](assets/components/cv-section-none.png)

The `"none"` mode keeps the title in the body text color. This is useful for a muted, monochrome layout.

```typ
#cv-section("Professional Experience", highlight-letters: 5)
```

![cv-section 5-letter custom highlight](assets/components/cv-section-custom-letters.png)

`highlight-letters` overrides the default value of 3. This is useful for a short title with more than one word.

---

### `cv-entry`

```typ
#cv-entry(
  title: [Senior Data Scientist],
  society: [Acme Analytics],
  date: [2022 -- 2024],
  location: [San Francisco, CA],
  description: list(
    [Led a team of 5 in building a real-time fraud detection pipeline.],
    [Reduced false-positive rate by 38% using gradient-boosted models.],
  ),
  tags: ([Python], [SQL], [Kubernetes]),
)
```

![cv-entry with all fields](assets/components/cv-entry-full.png)

The default value `[layout.entry] display_entry_society_first = true` puts the company name in bold on the first line, and the role under it. Tags render as pill-style badges.

```typ
#cv-entry(
  title: [Data Engineer],
  society: [Initech],
  date: [2018 -- 2020],
  location: [Austin, TX],
  description: [Built and maintained the company-wide data warehouse on Snowflake.],
)
```

![cv-entry without tags](assets/components/cv-entry-no-tags.png)

If you omit `tags:`, the tag block collapses completely and leaves no empty stripe.

When `display_entry_society_first = false`, the role becomes the bold anchor and the company moves under it. This is useful for an academic CV or a freelance CV, where the role is more important than the employer:

![cv-entry role-first layout](assets/components/cv-entry-role-first.png)

---

### Multiple Roles at One Company — `cv-entry-start` + `cv-entry-continued`

When one person had more than one title at the same employer, use this pair of components:

```typ
#cv-entry-start(
  society: [XYZ Corporation],
  location: [San Francisco, CA],
)
#cv-entry-continued(
  title: [Data Scientist],
  date: [2020 -- 2022],
  description: list([Built ML pipelines for product recommendations.]),
)
#cv-entry-continued(
  title: [Senior Data Scientist],
  date: [2022 -- 2024],
  description: list([Promoted to lead the personalization team.]),
)
```

![cv-entry-start + two continued](assets/components/cv-entry-start-continued.png)

!!! warning
    This pair needs `display_entry_society_first = true` in `metadata.toml`. If the layout is role-first, the pair panics with a clear message. For the actual error, see [`tests/panics/entry-start-needs-society-first`](https://github.com/yunanwg/brilliant-CV/tree/main/tests/panics).

---

### `cv-skill`

```typ
#cv-skill(
  type: [Languages],
  info: [English (native) #h-bar() Mandarin (fluent) #h-bar() French (B2)],
)
```

![cv-skill basic row](assets/components/cv-skill-basic.png)

This is the most simple skills row. The type label is on the left, and free-form content is on the right. Use `#h-bar()` to separate the items with the conventional inline bar.

---

### `cv-skill-with-level`

```typ
#cv-skill-with-level(
  type: [Python],
  level: 5,
  info: [Expert — daily for 8+ years],
)
```

![cv-skill-with-level at 5/5](assets/components/cv-skill-with-level-5.png)

Five circles, filled or empty, show the level. Pass an integer from 0 to 5. The function does not clamp the value, so a value outside that range renders the wrong number of circles.

---

### `cv-skill-tag`

```typ
#cv-skill-tag([Python])
#cv-skill-tag([SQL])
#cv-skill-tag([AWS])
#cv-skill-tag([Kubernetes])
```

![cv-skill-tag pill badges](assets/components/cv-skill-tag-basic.png)

Pill-style badges. These are useful in a `cv-skill` info field, for certifications or tech stacks where each item needs visual weight.

---

### `cv-honor`

```typ
#cv-honor(
  date: [2022],
  title: [AWS Certified Security — Specialty],
  issuer: [Amazon Web Services],
  url: "https://aws.amazon.com/certification/certified-security-specialty/",
  location: [Online],
)
```

![cv-honor with link](assets/components/cv-honor-with-url.png)

When you set `url`, the title becomes a clickable link in the PDF. If you omit `url`, the title renders as plain bold text:

![cv-honor without link](assets/components/cv-honor-no-url.png)

---

### `cv-publication`

```typ
#cv-publication(
  bib: bibliography("assets/publications.bib"),
  key-list: ("smith2020", "jones2021"),
  ref-style: "ieee",
  ref-full: false,
)
```

This component renders a Typst `bibliography` object with the style of the rest of the CV. To show every entry from the bib file, set `ref-full: true`. To show only selected entries, set `ref-full: false` and give their keys in `key-list:`. `ref-style:` accepts any [typst bibliography style](https://typst.app/docs/reference/model/bibliography/), such as `"apa"`, `"ieee"`, or `"chicago-author-date"`.

!!! tip
    This page has no visual example for `cv-publication`, because the output depends on your bib file. For a working example with the bundled `template/assets/publications.bib`, see [`template/profile_en/publications.typ`](https://github.com/yunanwg/brilliant-CV/blob/main/template/profile_en/publications.typ).
