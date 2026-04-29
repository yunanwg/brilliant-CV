// Regression: full Italian profile rendered end-to-end. See regression/cv-en
// for the pattern (profile photo suppressed; goes via /src/lib.typ direct).

#import "/src/lib.typ": cv

#let metadata = toml("/template/profile_it/metadata.toml")
#let metadata = (
  ..metadata,
  layout: (
    ..metadata.layout,
    header: (..metadata.layout.header, display_profile_photo: false),
  ),
)

#show: cv.with(metadata)

#include "/template/profile_it/education.typ"
#include "/template/profile_it/professional.typ"
#include "/template/profile_it/projects.typ"
#include "/template/profile_it/certificates.typ"
#include "/template/profile_it/publications.typ"
#include "/template/profile_it/skills.typ"
