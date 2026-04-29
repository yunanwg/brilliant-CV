// _set-accent-color falls through to rgb() parsing when the awesome_color
// value is not a preset key — supports arbitrary hex codes.

#import "/src/utils/styles.typ": _awesome-colors, _set-accent-color

#assert.eq(
  _set-accent-color(_awesome-colors, (layout: (awesome_color: "#1E90FF"))),
  rgb("#1E90FF"),
)
#assert.eq(
  _set-accent-color(_awesome-colors, (layout: (awesome_color: "#000000"))),
  rgb("#000000"),
)
