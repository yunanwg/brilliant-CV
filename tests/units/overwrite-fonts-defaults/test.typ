// overwrite-fonts returns the default Latin chain when [layout.fonts] is
// absent from metadata.

#import "/src/utils/styles.typ": overwrite-fonts

#let result = overwrite-fonts(
  (layout: (:)),
  ("Source Sans 3", "Linux Libertine"),
  "Roboto",
)

#assert.eq(result.regular-fonts, ("Source Sans 3", "Linux Libertine"))
#assert.eq(result.header-font, "Roboto")
