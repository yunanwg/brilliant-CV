// cv-skill-with-level at level 1 — boundary case, only the first circle
// is solid.

#import "/src/cv.typ": cv-metadata, cv-skill-with-level
#import "/src/utils/styles.typ": _latin-font-list, _regular-colors
#import "/tests/common.typ": minimal-metadata

#set page(width: 14cm, height: auto, margin: 0.5cm)
#set text(font: _latin-font-list, size: 9pt, fill: _regular-colors.lightgray)
#cv-metadata.update(minimal-metadata)

#cv-skill-with-level(
  type: [Rust],
  level: 1,
  info: [Beginner — read but rarely write],
)
