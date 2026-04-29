/*
 * Shared test fixtures. Imported by component + regression tests.
 *
 * Tytanic only discovers files literally named `test.typ` under tests/<name>/.
 * This file does not match that pattern, so it's invisible to `tt run` and
 * `tt list` while still being importable from any test via:
 *
 *     #import "/tests/common.typ": minimal-metadata
 *
 * The `/`-prefixed path resolves against the project root (the directory
 * containing typst.toml), so this works regardless of test depth.
 */

// Minimal metadata that satisfies cv()'s required schema. Footer is off
// so component snapshots stay focused on the component under test.
//
// Edit with care: changing any field here flips every component-level ref
// PNG. Prefer constructing local overrides in the test rather than mutating
// this fixture.
#let minimal-metadata = (
  header_quote: "",
  cv_footer: "Test CV",
  letter_footer: "Test Letter",
  layout: (
    awesome_color: "skyblue",
    before_section_skip: "1pt",
    before_entry_skip: "1pt",
    before_entry_description_skip: "1pt",
    paper_size: "a4",
    date_width: "3.6cm",
    fonts: (
      regular_fonts: (
        "Source Sans 3",
        "Linux Libertine",
        "Font Awesome 6 Free",
        "Font Awesome 6 Brands",
      ),
      header_font: "Roboto",
    ),
    header: (
      header_align: "left",
      display_profile_photo: false,
      info_font_size: "10pt",
    ),
    entry: (
      display_entry_society_first: true,
      display_logo: false,
    ),
    footer: (
      display_page_counter: false,
      display_footer: false,
    ),
    section: (
      title_highlight: "first-letters",
      title_highlight_letters: 3,
    ),
  ),
  personal: (
    first_name: "Jane",
    last_name: "Doe",
    info: (
      email: "jane.doe@example.com",
    ),
  ),
)

// Variant with display_name set (CJK convention) — exercises the
// _make-header-name-section display-name branch in src/cv.typ.
#let metadata-with-display-name = (
  ..minimal-metadata,
  personal: (
    ..minimal-metadata.personal,
    display_name: "Jane Q. Doe",
  ),
)

// Variant with full-title highlight (CJK / non-Latin section convention).
#let metadata-section-full = (
  ..minimal-metadata,
  layout: (
    ..minimal-metadata.layout,
    section: (
      title_highlight: "full",
      title_highlight_letters: 3,
    ),
  ),
)

// Variant with no section highlight at all.
#let metadata-section-none = (
  ..minimal-metadata,
  layout: (
    ..minimal-metadata.layout,
    section: (
      title_highlight: "none",
      title_highlight_letters: 3,
    ),
  ),
)

// Variant with custom highlight letter count (5 instead of default 3).
#let metadata-section-five-letters = (
  ..minimal-metadata,
  layout: (
    ..minimal-metadata.layout,
    section: (
      title_highlight: "first-letters",
      title_highlight_letters: 5,
    ),
  ),
)

// Variant with role-first entry layout (display_entry_society_first = false).
#let metadata-role-first = (
  ..minimal-metadata,
  layout: (
    ..minimal-metadata.layout,
    entry: (
      display_entry_society_first: false,
      display_logo: false,
    ),
  ),
)
