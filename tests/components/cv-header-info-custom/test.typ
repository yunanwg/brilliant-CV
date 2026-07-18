// Custom header info supports caller-controlled separators, line breaks, and
// local color overrides while retaining the default info typography.

#import "/src/lib.typ": cv, h-bar
#import "/tests/common.typ": minimal-metadata

#let metadata = (..minimal-metadata, header_quote: none)
#let info = metadata.personal.info

#show: cv.with(
  metadata,
  header-info: [
    #link("mailto:" + info.email)[#info.email]
    #h-bar()
    #text(fill: black)[Berlin, Germany]
    #linebreak()
    #text(fill: rgb("#2E7D32"))[Available for remote work]
  ],
)

[Body content]
