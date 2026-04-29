// Regression: full German profile rendered end-to-end. See regression/cv-en
// for the pattern (profile photo suppressed; goes via /src/lib.typ direct).

#import "/src/lib.typ": cv

#let metadata = toml("/template/profile_de/metadata.toml")
#let metadata = (
  ..metadata,
  layout: (
    ..metadata.layout,
    header: (..metadata.layout.header, display_profile_photo: false),
  ),
)

#show: cv.with(metadata)

#include "/template/profile_de/education.typ"
#include "/template/profile_de/professional.typ"
#include "/template/profile_de/projects.typ"
#include "/template/profile_de/certificates.typ"
#include "/template/profile_de/publications.typ"
#include "/template/profile_de/skills.typ"
