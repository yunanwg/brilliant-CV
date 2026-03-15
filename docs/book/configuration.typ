#import "/docs/book/book.typ": book-page

#show: book-page.with(title: "Configuration")

= Configuration via `metadata.toml`

All customization is done through `metadata.toml`. You can also override `language` at compile time:

```bash
typst compile cv.typ --input language=fr
```

== Top-level Keys

- `language` — language code, e.g. `"en"`, `"fr"`, `"zh"`. Must match a `modules_<lang>/` folder.

== `[layout]`

- `awesome_color` — accent color: `skyblue`, `red`, `nephritis`, `concrete`, `darknight`
- `font_size` — e.g. `"9pt"`
- `paper_size` — `"a4"` or `"us-letter"`
- `before_section_skip`, `before_entry_skip`, `before_entry_description_skip` — spacing controls

== `[layout.header]`

- `header_align` — `left`, `center`, or `right`
- `display_profile_photo` — `true` / `false`
- `profile_photo_path` — path to the profile photo image

== `[layout.entry]`

- `display_entry_society_first` — show organization before role (`true` enables `cv-entry-start` / `cv-entry-continued`)
- `display_logo` — show organization logo

== `[inject]`

- `custom_ai_prompt_text` — custom AI prompt text injected as hidden content
- `injected_keywords_list` — list of keywords injected as hidden content for ATS

== `[personal]`

- `first_name`, `last_name`
- `[personal.info]` — contact fields: `github`, `linkedin`, `email`, `phone`, and more

== `[lang.<code>]`

Per-language strings:
- `header_quote` — tagline shown in the CV header
- `cv_footer`, `letter_footer` — footer text

== `[lang.non_latin]`

Required for CJK / Cyrillic languages:
- `name` — name in the non-Latin script
- `font` — font family to use (e.g. `"Heiti SC"`)
