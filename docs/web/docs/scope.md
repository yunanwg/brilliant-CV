# Design Scope

brilliant-CV keeps a small set of configuration options, so that the common path stays simple. Each new option is a long-term commitment for documentation, tests, and compatibility. [CONTRIBUTING.md §4.2](https://github.com/yunanwg/brilliant-CV/blob/main/CONTRIBUTING.md#42-public-api-design) gives the full rules.

This page lists the requests that come back often. Before you open a feature request, find your request here.

## Already Possible

Many requests from older issues are now possible with the configuration or with a function argument.

| Request | How to do it | Related issues |
|---|---|---|
| Change the size, weight, style, color, or font of one kind of text | `[layout.parts.<name>]` in `metadata.toml`. See [Restyle One Part of the Text](recipes.md#restyle-one-part-of-the-text). | [#58](https://github.com/yunanwg/brilliant-CV/issues/58), [#70](https://github.com/yunanwg/brilliant-CV/issues/70), [#138](https://github.com/yunanwg/brilliant-CV/issues/138), [#190](https://github.com/yunanwg/brilliant-CV/issues/190) |
| Use the accent color on all of the section title, or on none of it | `[layout.section] title_highlight = "full"` or `"none"`. `title_highlight_letters` sets the number of letters for `"first-letters"`. | [#137](https://github.com/yunanwg/brilliant-CV/issues/137) |
| A different color for one section or one entry | The `color` argument of `cv-section`, `cv-entry`, `cv-entry-start`, `cv-entry-continued`, or `cv-honor`. | [#153](https://github.com/yunanwg/brilliant-CV/issues/153) |
| An image or SVG file as a contact icon | The `custom-icons` argument of `cv()`. See [Custom Contact Icon with Image](recipes.md#custom-contact-icon-with-image). | [#59](https://github.com/yunanwg/brilliant-CV/issues/59), [#63](https://github.com/yunanwg/brilliant-CV/issues/63), [#171](https://github.com/yunanwg/brilliant-CV/issues/171) |
| Your own layout for the contact line in the header | The `header-info` argument of `cv()`. See [Custom Header Info](recipes.md#custom-header-info). | [#191](https://github.com/yunanwg/brilliant-CV/issues/191) |
| The role in bold above the company | `[layout.entry] display_entry_society_first = false` | [#62](https://github.com/yunanwg/brilliant-CV/issues/62) |
| A wider skill-type column | The `type-width` argument of `cv-skill`. | [#189](https://github.com/yunanwg/brilliant-CV/issues/189) |
| Page numbers, or no footer | `[layout.footer] display_page_counter = true`, or `display_footer = false` | [#98](https://github.com/yunanwg/brilliant-CV/issues/98), [#132](https://github.com/yunanwg/brilliant-CV/issues/132) |
| Compile more than one language from one project | One profile for each language, selected with `--input profile=<name>`. See [Switching Profiles at Compile Time](recipes.md#switching-profiles-at-compile-time). | [#13](https://github.com/yunanwg/brilliant-CV/issues/13), [#128](https://github.com/yunanwg/brilliant-CV/issues/128), [#142](https://github.com/yunanwg/brilliant-CV/issues/142) |
| A summary paragraph | A `cv-section` with plain text under it. | [#130](https://github.com/yunanwg/brilliant-CV/issues/130) |

## Not Planned

The package does not add options for these requests. Each one changes the structure of the layout, or serves the preference of few CVs. For each request, the table gives a different method.

| Request | Different method | Related issues |
|---|---|---|
| A two-column layout | Edit a copy of the package. See [Change the Layout Beyond the Configuration](recipes.md#change-the-layout-beyond-the-configuration). | [#22](https://github.com/yunanwg/brilliant-CV/issues/22) |
| A different order of the parts in the header, for example the quote above the contact line | Edit a copy of the package. | [#182](https://github.com/yunanwg/brilliant-CV/issues/182) |
| Logo size relative to the page, for example in a CV with columns | Edit a copy of the package. | [#174](https://github.com/yunanwg/brilliant-CV/issues/174) |
| More built-in icon sets, for example Academicons | Pass the icon as an image with `custom-icons`. | [#63](https://github.com/yunanwg/brilliant-CV/issues/63) |
| An option for each spacing value and each text size | Use `[layout.parts]` for text. For spacing, use `before_section_skip`, `before_entry_skip`, and `before_entry_description_skip` in `[layout]`. For other spacing, edit a copy of the package. | [#8](https://github.com/yunanwg/brilliant-CV/issues/8), [#70](https://github.com/yunanwg/brilliant-CV/issues/70) |

If more users ask for a request in this table, the decision can change. Add your use case to the related issue.

## Ask for Something New

If your request is not on this page, open a [feature request](https://github.com/yunanwg/brilliant-CV/issues/new/choose). Tell us:

- What your CV must show, and why the current components cannot show it.
- Whether other CVs are likely to need the same thing.

A request with a clear use case that many CVs share has a better chance.
