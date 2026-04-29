// cv-honor without url — title renders as plain bold text.

#import "/src/cv.typ": cv-honor, cv-metadata
#import "/src/utils/styles.typ": _latin-font-list, _regular-colors
#import "/tests/common.typ": minimal-metadata

#set page(width: 16cm, height: auto, margin: 0.5cm)
#set text(font: _latin-font-list, size: 9pt, fill: _regular-colors.lightgray)
#cv-metadata.update(minimal-metadata)

#cv-honor(
  date: [2021],
  title: [Best Paper Award],
  issuer: [ICML 2021],
  location: [Vienna, AT],
)
