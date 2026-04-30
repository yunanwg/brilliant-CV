// cv-entry-start + cv-entry-continued — with-logo branch.
//
// Companion to cv-entry-start-continued (which exercises the no-logo branch
// via minimal-metadata's display_logo: false). Together they cover both
// code paths in the cv-entry-start spacing logic; see issue #172.

#import "/src/cv.typ": cv-entry-continued, cv-entry-start, cv-metadata
#import "/src/utils/styles.typ": _latin-font-list, _regular-colors
#import "/tests/common.typ": minimal-metadata

#let metadata-with-logo = (
  ..minimal-metadata,
  layout: (
    ..minimal-metadata.layout,
    entry: (
      display_entry_society_first: true,
      display_logo: true,
    ),
  ),
)

#set page(width: 16cm, height: auto, margin: 0.5cm)
#set text(font: _latin-font-list, size: 9pt, fill: _regular-colors.lightgray)
#cv-metadata.update(metadata-with-logo)

#cv-entry-start(
  society: [XYZ Corporation],
  location: [San Francisco, CA],
  logo: image("/template/assets/logos/xyz_corp.png"),
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
