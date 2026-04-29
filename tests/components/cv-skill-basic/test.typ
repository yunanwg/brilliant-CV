// cv-skill with type + info — the simplest skills variant, used for free-form
// skill rows like "Languages: English, Mandarin, French".

#import "/src/cv.typ": cv-metadata, cv-skill
#import "/src/utils/styles.typ": _latin-font-list, _regular-colors
#import "/tests/common.typ": minimal-metadata

#set page(width: 14cm, height: auto, margin: 0.5cm)
#set text(font: _latin-font-list, size: 9pt, fill: _regular-colors.lightgray)
#cv-metadata.update(minimal-metadata)

#cv-skill(
  type: [Languages],
  info: [English (native), Mandarin (fluent), French (B2)],
)
