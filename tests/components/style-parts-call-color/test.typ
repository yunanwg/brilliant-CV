// [layout.parts] fill recolors the accent-colored parts of a section, an
// entry, and an honor, but a color: argument on one call still wins there.
// Top half: the configured fill (green). Bottom half: color: red.

#import "/src/cv.typ": cv-entry, cv-honor, cv-section
#import "/src/utils/styles.typ": _regular-colors
#import "/tests/common.typ": minimal-metadata, test-font-list

#set page(width: 16cm, height: auto, margin: 0.5cm)
#set text(font: test-font-list, size: 9pt, fill: _regular-colors.lightgray)

#let metadata = (
  ..minimal-metadata,
  layout: (
    ..minimal-metadata.layout,
    parts: (
      "section-title": (fill: "nephritis"),
      "entry-primary-aside": (fill: "nephritis"),
      "entry-secondary": (fill: "nephritis"),
      "honor-location": (fill: "nephritis"),
    ),
  ),
)

#for color in (none, red) {
  cv-section("Experience", color: color, metadata: metadata)
  cv-entry(
    title: [Senior Data Scientist],
    society: [Acme Analytics],
    date: [2022 -- 2024],
    location: [San Francisco, CA],
    color: color,
    metadata: metadata,
  )
  cv-honor(
    date: [2022],
    title: [Award],
    issuer: [Acme],
    location: [Online],
    color: color,
    metadata: metadata,
  )
}
