// cv-section with title_highlight_letters = 5 — first 5 chars in accent
// color instead of the default 3.

#import "/src/cv.typ": cv-metadata, cv-section
#import "/src/utils/styles.typ": _latin-font-list, _regular-colors
#import "/tests/common.typ": metadata-section-five-letters

#set page(width: 12cm, height: auto, margin: 0.5cm)
#set text(font: _latin-font-list, size: 9pt, fill: _regular-colors.lightgray)
#cv-metadata.update(metadata-section-five-letters)

#cv-section("Professional Experience")
