// Shared fixture for the style-parts tests: metadata that renders every
// CV and letter part, and one call to every CV component.

#import "/src/lib.typ": (
  cv-entry, cv-honor, cv-publication, cv-section, cv-skill, cv-skill-tag,
  cv-skill-with-level,
)
#import "/src/utils/parts.typ": _part-names
#import "/tests/common.typ": minimal-metadata

#let letter-part-names = _part-names.filter(name => (
  name.starts-with("letter-") or name == "footer"
))
#let cv-part-names = _part-names.filter(name => not name.starts-with("letter-"))

// Every part shows up: a header quote, and the footer turned on.
#let every-part-metadata = (
  ..minimal-metadata,
  header_quote: "Data science lead",
  layout: (
    ..minimal-metadata.layout,
    footer: (display_page_counter: false, display_footer: true),
  ),
)

// The same metadata with every part set to one color.
#let themed-metadata = (
  ..every-part-metadata,
  layout: (
    ..every-part-metadata.layout,
    parts: _part-names.map(name => (name, (fill: "nephritis"))).to-dict(),
  ),
)

#let every-cv-component() = {
  cv-section("Experience")
  cv-entry(
    title: [Senior Data Scientist],
    society: [Acme Analytics],
    date: [2022 -- 2024],
    location: [San Francisco, CA],
    description: list([Built forecasting models.]),
    tags: ([Python],),
  )
  cv-section("Skills")
  cv-skill(type: [Languages], info: [English])
  cv-skill-with-level(type: [Python], level: 4, info: [Advanced])
  cv-skill-tag([SQL])
  cv-section("Honors")
  cv-honor(date: [2022], title: [Award], issuer: [Acme], location: [Online])
  cv-section("Publications")
  cv-publication(
    bib: bibliography("/template/assets/publications.bib"),
    key-list: ("smith2020",),
    ref-full: false,
  )
}
