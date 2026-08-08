// Regression for #187: title slicing counts grapheme clusters, not UTF-8 bytes.
// The short non-ASCII title also guards against slicing beyond the cluster array.

#import "/src/cv.typ": cv-metadata, cv-section
#import "/src/utils/styles.typ": _regular-colors
#import "/tests/common.typ": minimal-metadata

#set page(width: 12cm, height: auto, margin: 0.5cm)
#set text(font: ("Source Sans 3",), size: 9pt, fill: _regular-colors.lightgray)
#cv-metadata.update(minimal-metadata)

#cv-section("Hänsel", highlight-letters: 3)
#cv-section("Hä", highlight-letters: 3)
