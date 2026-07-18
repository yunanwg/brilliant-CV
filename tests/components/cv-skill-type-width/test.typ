// Skill rows with a wider type column for long labels.

#import "/src/cv.typ": cv-metadata, cv-skill, cv-skill-with-level
#import "/src/utils/styles.typ": _regular-colors
#import "/tests/common.typ": minimal-metadata, test-font-list

#set page(width: 14cm, height: auto, margin: 0.5cm)
#set text(font: test-font-list, size: 9pt, fill: _regular-colors.lightgray)
#cv-metadata.update(minimal-metadata)

#cv-skill(
  type: [Programming Languages],
  info: [Python, Rust, and TypeScript],
  type-width: 32%,
)
#cv-skill-with-level(
  type: [Natural Languages],
  level: 4,
  info: [English and French],
  type-width: 32%,
)
