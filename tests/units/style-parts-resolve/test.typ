// _resolve-parts turns [layout.parts] into `text` arguments: lengths are
// parsed, colors accept awesome names and hex, other values pass through.

#import "/src/utils/parts.typ": _resolve-parts
#import "/src/utils/styles.typ": _awesome-colors
#import "/tests/common.typ": minimal-metadata

#assert.eq(_resolve-parts(minimal-metadata, _awesome-colors), (:))

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
#let parts = _resolve-parts(metadata, _awesome-colors)
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
  _resolve-parts(hex, _awesome-colors).at("entry-primary").fill,
  rgb("#123456"),
)
