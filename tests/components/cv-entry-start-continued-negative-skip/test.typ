// Regression for issue #243: tuning before_entry_skip must not change the
// company -> first role gap inside a start/continued group.

#import "/src/cv.typ": cv-entry, cv-entry-continued, cv-entry-start, cv-metadata
#import "/src/utils/styles.typ": _regular-colors
#import "/tests/common.typ": minimal-metadata, test-font-list

#let metadata-negative-skip = (
  ..minimal-metadata,
  layout: (
    ..minimal-metadata.layout,
    before_entry_skip: "-2pt",
  ),
)

#set page(width: 16cm, height: auto, margin: 0.5cm)
#set text(font: test-font-list, size: 9pt, fill: _regular-colors.lightgray)
#cv-metadata.update(metadata-negative-skip)

#cv-entry(
  title: [Analyst],
  society: [Acme Corp],
  date: [2024 -- ongoing],
  location: [Berlin],
)

#cv-entry-start(society: [Beta Inc], location: [Berlin])
#cv-entry-continued(title: [Analyst], date: [2022 -- 2024])
