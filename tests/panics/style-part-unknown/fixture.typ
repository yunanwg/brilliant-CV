// expected: unknown style part [layout.parts.entry-title]
//
// A misspelled or renamed part must fail loudly instead of leaving the CV
// silently unstyled.

#import "/src/lib.typ": cv, cv-entry
#import "/tests/common.typ": minimal-metadata

#let metadata = (
  ..minimal-metadata,
  layout: (..minimal-metadata.layout, parts: ("entry-title": (size: "11pt"))),
)
#show: cv.with(metadata)
#cv-entry(title: [Analyst], society: [ABC], date: [2020], location: [NY])
