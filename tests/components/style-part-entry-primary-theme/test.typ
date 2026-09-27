// [layout.parts.entry-primary] restyles the bold first line of an entry,
// in both layouts: the society (society-first, the default) and the title.

#import "/src/cv.typ": cv-entry, cv-metadata
#import "/src/utils/styles.typ": _regular-colors
#import "/tests/common.typ": minimal-metadata, test-font-list

#set page(width: 16cm, height: auto, margin: 0.5cm)
#set text(font: test-font-list, size: 9pt, fill: _regular-colors.lightgray)

#let themed(society-first) = (
  ..minimal-metadata,
  layout: (
    ..minimal-metadata.layout,
    entry: (
      ..minimal-metadata.layout.entry,
      display_entry_society_first: society-first,
    ),
    parts: ("entry-primary": (size: "13pt", weight: "regular", fill: "red")),
  ),
)

#for society-first in (true, false) {
  cv-entry(
    title: [Senior Data Scientist],
    society: [Acme Analytics],
    date: [2022 -- 2024],
    location: [San Francisco, CA],
    metadata: themed(society-first),
  )
}
