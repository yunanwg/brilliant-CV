// overwrite-fonts replaces both regular_fonts and header_font when the
// user provides a [layout.fonts] override (e.g. for a CJK profile).

#import "/src/utils/styles.typ": overwrite-fonts

#let metadata = (
  layout: (
    fonts: (
      regular_fonts: ("Source Sans 3", "Heiti SC"),
      header_font: "Heiti SC",
    ),
  ),
)

#let result = overwrite-fonts(
  metadata,
  ("Source Sans 3", "Linux Libertine"),
  "Roboto",
)

#assert.eq(result.regular-fonts, ("Source Sans 3", "Heiti SC"))
#assert.eq(result.header-font, "Heiti SC")
