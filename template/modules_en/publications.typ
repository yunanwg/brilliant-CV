// Imports
#import "@preview/brilliant-cv:2.0.6": cv-section, cv-publication
#let metadata = toml("../metadata.toml")
#let cv-section = cv-section.with(metadata: metadata)


#cv-section("Publications")

// Example 1: Selected publications with custom style
#cv-publication(
  bib: bibliography("../src/publications.bib"),
  key-list: (
    "smith2020",
    "jones2021",
    "wilson2022",
  ),
  ref-style: "ieee",
  ref-full: false,
)

// Example 2: All publications with APA style (commented out to avoid duplication)
// #cv-publication(
//   bib: bibliography("../src/publications.bib"),
//   ref-style: "apa",
//   ref-full: true,
// )
