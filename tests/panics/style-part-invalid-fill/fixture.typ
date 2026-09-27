// expected: [layout.parts.entry-primary] fill must be a color name
//
// A misspelled color names the metadata key instead of failing inside rgb().

#import "/src/lib.typ": cv, cv-entry
#import "/tests/common.typ": minimal-metadata

#let metadata = (
  ..minimal-metadata,
  layout: (..minimal-metadata.layout, parts: ("entry-primary": (fill: "redd"))),
)
#show: cv.with(metadata)
#cv-entry(title: [Analyst], society: [ABC], date: [2020], location: [NY])
