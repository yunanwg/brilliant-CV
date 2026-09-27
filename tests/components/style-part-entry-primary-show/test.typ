// A show-set rule on <bcv-entry-primary> reaches the part (experimental):
// the package applies its defaults through a set rule, so the user's rule
// wins over them.

#import "/src/cv.typ": cv-entry, cv-metadata
#import "/src/utils/styles.typ": _regular-colors
#import "/tests/common.typ": minimal-metadata, test-font-list

#set page(width: 16cm, height: auto, margin: 0.5cm)
#set text(font: test-font-list, size: 9pt, fill: _regular-colors.lightgray)
#cv-metadata.update(minimal-metadata)

#show <bcv-entry-primary>: set text(size: 13pt, fill: rgb("#27AE60"))

#cv-entry(
  title: [Senior Data Scientist],
  society: [Acme Analytics],
  date: [2022 -- 2024],
  location: [San Francisco, CA],
)
