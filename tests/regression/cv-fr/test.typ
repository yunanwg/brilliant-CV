// Regression: full French profile rendered end-to-end. See regression/cv-en
// for the pattern (profile photo suppressed; goes via /src/lib.typ direct).

#import "/src/lib.typ": cv

#let metadata = toml("/template/profile_fr/metadata.toml")
#let metadata = (
  ..metadata,
  layout: (
    ..metadata.layout,
    header: (..metadata.layout.header, display_profile_photo: false),
  ),
)

#show: cv.with(metadata)

#include "/template/profile_fr/education.typ"
#include "/template/profile_fr/professional.typ"
#include "/template/profile_fr/projects.typ"
#include "/template/profile_fr/certificates.typ"
#include "/template/profile_fr/publications.typ"
#include "/template/profile_fr/skills.typ"
