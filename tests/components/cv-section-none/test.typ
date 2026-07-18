// cv-section with title_highlight = "none" — entire title in black, no
// accent highlighting.

#import "/src/cv.typ": cv-metadata, cv-section
#import "/src/utils/styles.typ": _regular-colors
#import "/tests/common.typ": metadata-section-none, test-font-list

#set page(width: 12cm, height: auto, margin: 0.5cm)
#set text(font: test-font-list, size: 9pt, fill: _regular-colors.lightgray)
#cv-metadata.update(metadata-section-none)

#cv-section("Education")
