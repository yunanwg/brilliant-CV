// _resolve-parts turns [layout.parts] into `text` arguments: lengths are
// parsed, colors accept awesome names and hex, other values pass through.

#import "/src/utils/parts.typ": _resolve-parts, _yield-fill
#import "/src/utils/styles.typ": _awesome-colors
#import "/tests/common.typ": minimal-metadata

#assert.eq(_resolve-parts(minimal-metadata), (:))

#let metadata = (
  ..minimal-metadata,
  layout: (
    ..minimal-metadata.layout,
    parts: (
      "entry-primary": (
        size: "11pt",
        weight: 600,
        style: "italic",
        fill: "red",
        font: ("Source Sans 3",),
      ),
    ),
  ),
)
#let parts = _resolve-parts(metadata)
#assert.eq(parts.at("entry-primary").size, 11pt)
#assert.eq(parts.at("entry-primary").weight, 600)
#assert.eq(parts.at("entry-primary").style, "italic")
#assert.eq(parts.at("entry-primary").fill, _awesome-colors.red)
#assert.eq(parts.at("entry-primary").font, ("Source Sans 3",))

#let hex = (
  ..minimal-metadata,
  layout: (
    ..minimal-metadata.layout,
    parts: ("entry-primary": (fill: "#123456")),
  ),
)
#assert.eq(
  _resolve-parts(hex).at("entry-primary").fill,
  rgb("#123456"),
)

// An explicit per-call color drops the configured fill of the parts it
// colors, and keeps every other property.
#let both = (
  "section-title": (fill: rgb("#123456"), size: 20pt),
  "honor-title": (fill: rgb("#123456")),
)
#assert.eq(_yield-fill(both, none, ("section-title",)), both)
#assert.eq(
  _yield-fill(both, red, ("section-title", "entry-tag")),
  ("section-title": (size: 20pt), "honor-title": (fill: rgb("#123456"))),
)
