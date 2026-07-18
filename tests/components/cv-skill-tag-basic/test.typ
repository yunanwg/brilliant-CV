// cv-skill-tag — pill-style skill badges, multiple stacked.

#import "/src/cv.typ": cv-metadata, cv-skill-tag
#import "/src/utils/styles.typ": _regular-colors
#import "/tests/common.typ": minimal-metadata, test-font-list

#set page(width: 14cm, height: auto, margin: 0.5cm)
#set text(font: test-font-list, size: 9pt, fill: _regular-colors.lightgray)
#cv-metadata.update(minimal-metadata)

#cv-skill-tag([Python])
#cv-skill-tag([SQL])
#cv-skill-tag([AWS])
#cv-skill-tag([Kubernetes])
