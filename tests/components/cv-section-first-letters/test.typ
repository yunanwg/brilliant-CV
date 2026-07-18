// cv-section with default title_highlight = "first-letters" — the leading
// 3 grapheme clusters of the title render in the accent color (Latin convention).

#import "/src/cv.typ": cv-metadata, cv-section
#import "/src/utils/styles.typ": _regular-colors
#import "/tests/common.typ": minimal-metadata, test-font-list

#set page(width: 12cm, height: auto, margin: 0.5cm)
#set text(font: test-font-list, size: 9pt, fill: _regular-colors.lightgray)
#cv-metadata.update(minimal-metadata)

#cv-section("Education")
