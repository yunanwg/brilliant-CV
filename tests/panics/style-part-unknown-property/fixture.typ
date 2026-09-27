// expected: unknown property [layout.parts.entry-primary] color
//
// Only the documented text properties are accepted.

#import "/src/lib.typ": cv, cv-entry
#import "/tests/common.typ": minimal-metadata

#let metadata = (
  ..minimal-metadata,
  layout: (..minimal-metadata.layout, parts: ("entry-primary": (color: "red"))),
)
#show: cv.with(metadata)
#cv-entry(title: [Analyst], society: [ABC], date: [2020], location: [NY])
