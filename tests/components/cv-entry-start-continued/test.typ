// cv-entry-start + cv-entry-continued — multi-role pattern at one company.

#import "/src/cv.typ": cv-entry-continued, cv-entry-start, cv-metadata
#import "/src/utils/styles.typ": _latin-font-list, _regular-colors
#import "/tests/common.typ": minimal-metadata

#set page(width: 16cm, height: auto, margin: 0.5cm)
#set text(font: _latin-font-list, size: 9pt, fill: _regular-colors.lightgray)
#cv-metadata.update(minimal-metadata)

#cv-entry-start(
  society: [XYZ Corporation],
  location: [San Francisco, CA],
)
#cv-entry-continued(
  title: [Data Scientist],
  date: [2020 -- 2022],
  description: list(
    [Built ML pipelines for product recommendations.],
  ),
)
#cv-entry-continued(
  title: [Senior Data Scientist],
  date: [2022 -- 2024],
  description: list(
    [Promoted to lead the personalization team.],
  ),
)
