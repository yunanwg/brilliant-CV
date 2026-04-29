// cv-section with title_highlight = "full" — entire title in accent color.
// CJK / non-Latin convention; demoed by profile_zh.

#import "/src/cv.typ": cv-metadata, cv-section
#import "/src/utils/styles.typ": _latin-font-list, _regular-colors
#import "/tests/common.typ": metadata-section-full

#set page(width: 12cm, height: auto, margin: 0.5cm)
#set text(font: _latin-font-list, size: 9pt, fill: _regular-colors.lightgray)
#cv-metadata.update(metadata-section-full)

#cv-section("Education")
