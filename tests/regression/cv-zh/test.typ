// Regression: full Chinese profile rendered end-to-end.
//
// profile_zh ships with Heiti SC (macOS-default) for the CJK fonts. The
// Linux Docker baseline doesn't have Heiti SC (not freely redistributable),
// so the test fixture overrides [layout.fonts] to Noto Sans CJK SC — the
// canonical free CJK font, installed in tests/Dockerfile. The point of the
// regression test is "mixed-script profile renders without errors and the
// layout is stable", not "Heiti SC visually matches" — the latter is a
// font-choice concern verified manually by the maintainer on macOS.

#import "/src/lib.typ": cv

#let metadata = toml("/template/profile_zh/metadata.toml")
#let metadata = (
  ..metadata,
  layout: (
    ..metadata.layout,
    header: (..metadata.layout.header, display_profile_photo: false),
    fonts: (
      regular_fonts: ("Source Sans 3", "Noto Sans CJK SC"),
      header_font: "Noto Sans CJK SC",
    ),
  ),
)

#show: cv.with(metadata)

#include "/template/profile_zh/education.typ"
#include "/template/profile_zh/professional.typ"
#include "/template/profile_zh/projects.typ"
#include "/template/profile_zh/certificates.typ"
#include "/template/profile_zh/publications.typ"
#include "/template/profile_zh/skills.typ"
