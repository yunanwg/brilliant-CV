// _set-accent-color resolves a preset palette key (e.g. "red") to the
// corresponding rgb() color from _awesome-colors.

#import "/src/utils/styles.typ": _awesome-colors, _set-accent-color

#assert.eq(
  _set-accent-color(_awesome-colors, (layout: (awesome_color: "red"))),
  rgb("#DC3522"),
)
#assert.eq(
  _set-accent-color(_awesome-colors, (layout: (awesome_color: "skyblue"))),
  rgb("#0395DE"),
)
#assert.eq(
  _set-accent-color(_awesome-colors, (layout: (awesome_color: "nephritis"))),
  rgb("#27AE60"),
)
