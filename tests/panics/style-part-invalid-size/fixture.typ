// expected: [layout.parts.entry-primary] size must be a length
//
// A size that is not a length is rejected with the offending value.

#import "/src/lib.typ": cv, cv-entry
#import "/tests/common.typ": minimal-metadata

#let metadata = (
  ..minimal-metadata,
  layout: (..minimal-metadata.layout, parts: ("entry-primary": (size: "big"))),
)
#show: cv.with(metadata)
#cv-entry(title: [Analyst], society: [ABC], date: [2020], location: [NY])
