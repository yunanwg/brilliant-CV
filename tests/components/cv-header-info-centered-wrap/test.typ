// A generated contact row that wraps must center every line and never end
// a line with a separator: the row is packed into lines by measured width,
// with separators only between items on the same line.

#import "/src/lib.typ": cv
#import "/tests/common.typ": minimal-metadata

#let metadata = (
  ..minimal-metadata,
  header_quote: none,
  layout: (
    ..minimal-metadata.layout,
    header: (..minimal-metadata.layout.header, header_align: "center"),
  ),
  personal: (
    ..minimal-metadata.personal,
    info: (
      github: "jane-doe-example",
      phone: "+1 (415) 555-0199",
      email: "jane.doe@example.com",
      linkedin: "jane-doe-example",
      homepage: "jane-doe.example.com",
      location: "San Francisco, CA",
    ),
  ),
)

#show: cv.with(metadata)
