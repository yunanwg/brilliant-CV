// cv-honor with url — title becomes a clickable link to the issuer.

#import "/src/cv.typ": cv-honor, cv-metadata
#import "/src/utils/styles.typ": _latin-font-list, _regular-colors
#import "/tests/common.typ": minimal-metadata

#set page(width: 16cm, height: auto, margin: 0.5cm)
#set text(font: _latin-font-list, size: 9pt, fill: _regular-colors.lightgray)
#cv-metadata.update(minimal-metadata)

#cv-honor(
  date: [2022],
  title: [AWS Certified Security — Specialty],
  issuer: [Amazon Web Services],
  url: "https://aws.amazon.com/certification/certified-security-specialty/",
  location: [Online],
)
