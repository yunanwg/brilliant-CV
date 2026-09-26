// Documented contract: [layout] font_size applies only to the CV. The
// letter body stays at 12pt, and a `set text(size: ...)` rule after the
// show rule overrides it (docs/web/docs/components.md, letter()).

#import "/src/lib.typ": letter
#import "/tests/common.typ": minimal-metadata

#let metadata = (
  ..minimal-metadata,
  layout: (..minimal-metadata.layout, font_size: "20pt"),
)

#show: letter.with(metadata, date: "2026-01-01")

#context assert.eq(text.size, 12pt)

#set text(size: 11pt)
#context assert.eq(text.size, 11pt)
