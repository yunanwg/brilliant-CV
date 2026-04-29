# Component Gallery

These are the building blocks of your CV. Each example below is followed by the actual rendered output — the PNGs are the same ones the [test suite](https://github.com/yunanwg/brilliant-CV/tree/main/tests/components) uses as visual-regression baselines, so what you see here is exactly what the package produces. For full parameter details, see the [API Reference](api-reference.md).

## Entry Point Functions

### `cv()`

```typ
#show: cv.with(
  metadata,
  profile-photo: image("assets/avatar.png"),
)
```

The `cv()` function is the main entry point. It runs schema-migration guards (panic on v3 fields), sets page layout, applies fonts, renders the header, and emits `_cv-footer` on every page. All your CV modules go inside its body.

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

`letter()` mirrors `cv()` for cover-letter pages with letter-formal margins and a 12pt body. `sender-address` defaults to `auto`, which reads `metadata.personal.address` (falls back to `"Your Address Here"` if unset). Use `address-style: "normal"` to disable smallcaps on addresses.

---

## CV Components

### `cv-section`

```typ
#cv-section("Education")
```

![cv-section first-letters mode](assets/components/cv-section-first-letters.png)

The default `[layout.section] title_highlight = "first-letters"` highlights the leading 3 chars in the accent color (Latin convention). Override per call with `highlight:` (`"first-letters"` / `"full"` / `"none"`) and `highlight_letters:` (int).

```typ
#cv-section("教育背景", highlight: "full")
```

![cv-section full mode](assets/components/cv-section-full.png)

`"full"` mode colors the entire title — the CJK convention used by `profile_zh`.

```typ
#cv-section("Education", highlight: "none")
```

![cv-section none mode](assets/components/cv-section-none.png)

`"none"` keeps the title in body text color — useful for muted, all-monochrome layouts.

```typ
#cv-section("Professional Experience", highlight_letters: 5)
```

![cv-section 5-letter custom highlight](assets/components/cv-section-custom-letters.png)

`highlight_letters` overrides the default of 3 — handy for short multi-word titles.

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

The default `[layout.entry] display_entry_society_first = true` puts the company name bold on top, role below. Tags render as pill-style badges.

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

Omitting `tags:` collapses the tag block entirely (no empty stripe).

When `display_entry_society_first = false`, the role becomes the bold anchor and the company moves below — useful for academic or freelance CVs where role hierarchy matters more than employer:

![cv-entry role-first layout](assets/components/cv-entry-role-first.png)

---

### Multiple Roles at One Company — `cv-entry-start` + `cv-entry-continued`

Use this pair when one person held multiple titles at the same employer:

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
    Requires `display_entry_society_first = true` in `metadata.toml`. The pair panics with a clear message if the layout is set to role-first — see [`tests/panics/entry-start-needs-society-first`](https://github.com/yunanwg/brilliant-CV/tree/main/tests/panics) for the actual error.

---

### `cv-skill`

```typ
#cv-skill(
  type: [Languages],
  info: [English (native) #h-bar() Mandarin (fluent) #h-bar() French (B2)],
)
```

![cv-skill basic row](assets/components/cv-skill-basic.png)

The simplest skills row — type label on the left, free-form content on the right. Use `#h-bar()` to separate items with the conventional inline bar.

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

Five filled/empty circles render the level. Pass an integer in the range 0–5; the function does not clamp, so a value outside that range will render the wrong number of circles.

---

### `cv-skill-tag`

```typ
#cv-skill-tag([Python])
#cv-skill-tag([SQL])
#cv-skill-tag([AWS])
#cv-skill-tag([Kubernetes])
```

![cv-skill-tag pill badges](assets/components/cv-skill-tag-basic.png)

Pill-style badges. Useful inside a `cv-skill` info field for certifications or tech stacks where each item deserves visual weight.

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

When `url` is set, the title becomes a clickable link in the rendered PDF. Omit `url` to render the title as plain bold text:

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

Renders a typst `bibliography` object styled to match the rest of the CV. Set `ref-full: true` to show every entry from the bib file; pair `ref-full: false` with `key-list:` to publish only the entries whose keys you want featured. `ref-style:` accepts any [typst bibliography style](https://typst.app/docs/reference/model/bibliography/) (`"apa"`, `"ieee"`, `"chicago-author-date"`, …).

!!! tip
    Visual examples for `cv-publication` are not included here — the rendered output depends entirely on your bib file. See [`template/profile_en/publications.typ`](https://github.com/yunanwg/brilliant-CV/blob/main/template/profile_en/publications.typ) for a working example using the bundled `template/assets/publications.bib`.
