/// [skip]
//
// Regression: full Chinese profile rendered end-to-end. Uses Heiti SC
// (macOS-default) which CI Linux runners don't have, so this test is
// [skip]-annotated by default. Maintainer regenerates the ref locally
// on macOS via `tt run regression/cv-zh` (explicit name bypasses skip)
// or `just test-zh`. See tests/README.md for the full rationale.

#import "/src/lib.typ": cv

#let metadata = toml("/template/profile_zh/metadata.toml")
#let metadata = (
  ..metadata,
  layout: (
    ..metadata.layout,
    header: (..metadata.layout.header, display_profile_photo: false),
  ),
)

#show: cv.with(metadata)

#include "/template/profile_zh/education.typ"
#include "/template/profile_zh/professional.typ"
#include "/template/profile_zh/projects.typ"
#include "/template/profile_zh/certificates.typ"
#include "/template/profile_zh/publications.typ"
#include "/template/profile_zh/skills.typ"
