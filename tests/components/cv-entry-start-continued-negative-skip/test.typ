// cv-entry-start + cv-entry-continued with a tuned (negative) before_entry_skip.
//
// Regression for issue #243: the company -> title gap inside a
// start/continued group used to be governed by before_entry_skip (the
// between-entries knob), while a plain cv-entry's equivalent gap is a fixed
// row-gutter untouched by that setting. Profiles that tune before_entry_skip
// away from the 1pt default (e.g. to fit a dense CV on one page) made the
// two gaps visibly diverge. Both entry styles are rendered here so the
// snapshot fails if that divergence reappears.

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
