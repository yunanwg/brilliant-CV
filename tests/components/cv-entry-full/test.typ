// cv-entry with all optional fields populated, society-first layout
// (the default per minimal-metadata).

#import "/src/cv.typ": cv-entry, cv-metadata
#import "/src/utils/styles.typ": _latin-font-list, _regular-colors
#import "/tests/common.typ": minimal-metadata

#set page(width: 16cm, height: auto, margin: 0.5cm)
#set text(font: _latin-font-list, size: 9pt, fill: _regular-colors.lightgray)
#cv-metadata.update(minimal-metadata)

#cv-entry(
  title: [Senior Data Scientist],
  society: [Acme Analytics],
  date: [2022 -- 2024],
  location: [San Francisco, CA],
  description: list(
    [Led a team of 5 in building a real-time fraud detection pipeline.],
    [Reduced false-positive rate by 38% using gradient-boosted models.],
  ),
  tags: ([Python], [SQL], [Kubernetes]),
)
