// cv-skill-with-level at level 5 — boundary case, all five circles solid.

#import "/src/cv.typ": cv-metadata, cv-skill-with-level
#import "/src/utils/styles.typ": _latin-font-list, _regular-colors
#import "/tests/common.typ": minimal-metadata

#set page(width: 14cm, height: auto, margin: 0.5cm)
#set text(font: _latin-font-list, size: 9pt, fill: _regular-colors.lightgray)
#cv-metadata.update(minimal-metadata)

#cv-skill-with-level(
  type: [Python],
  level: 5,
  info: [Expert — daily for 8+ years],
)
