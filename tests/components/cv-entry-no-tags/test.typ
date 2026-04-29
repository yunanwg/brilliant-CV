// cv-entry without tags — verifies the tag-list block is fully omitted
// (no empty stripe).

#import "/src/cv.typ": cv-entry, cv-metadata
#import "/src/utils/styles.typ": _latin-font-list, _regular-colors
#import "/tests/common.typ": minimal-metadata

#set page(width: 16cm, height: auto, margin: 0.5cm)
#set text(font: _latin-font-list, size: 9pt, fill: _regular-colors.lightgray)
#cv-metadata.update(minimal-metadata)

#cv-entry(
  title: [Data Analyst],
  society: [Globex Corp.],
  date: [2020 -- 2022],
  location: [Remote],
  description: [Owned weekly executive metrics reporting across 4 product lines.],
)
