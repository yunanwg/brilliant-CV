// `header-info: none` removes the contact row without collapsing the spacing
// between a name-only header and the document body.

#import "/src/lib.typ": cv
#import "/tests/common.typ": minimal-metadata

#let metadata = (..minimal-metadata, header_quote: none)

#show: cv.with(metadata, header-info: none)

[Body content]
