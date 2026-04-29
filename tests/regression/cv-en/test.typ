// Regression: full English profile rendered end-to-end. Mirrors what a user
// gets from `typst compile cv.typ --input profile=en`, except:
//   - profile photo is suppressed (avatar.png byte changes flap diffs)
//   - tests go via /src/lib.typ directly, not @preview/brilliant-cv:4.0.0,
//     so the test pins the local source. Profile modules import the
//     published package by themselves; `just link` (or its CI equivalent)
//     must run before this test so that resolves to local src/.

#import "/src/lib.typ": cv

#let metadata = toml("/template/profile_en/metadata.toml")
#let metadata = (
  ..metadata,
  layout: (
    ..metadata.layout,
    header: (..metadata.layout.header, display_profile_photo: false),
  ),
)

#show: cv.with(metadata)

#include "/template/profile_en/education.typ"
#include "/template/profile_en/professional.typ"
#include "/template/profile_en/projects.typ"
#include "/template/profile_en/certificates.typ"
#include "/template/profile_en/publications.typ"
#include "/template/profile_en/skills.typ"
