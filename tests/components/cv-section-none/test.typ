// cv-section with title_highlight = "none" — entire title in black, no
// accent highlighting.

#import "/src/cv.typ": cv-metadata, cv-section
#import "/src/utils/styles.typ": _latin-font-list, _regular-colors
#import "/tests/common.typ": metadata-section-none

#set page(width: 12cm, height: auto, margin: 0.5cm)
#set text(font: _latin-font-list, size: 9pt, fill: _regular-colors.lightgray)
#cv-metadata.update(metadata-section-none)

#cv-section("Education")
