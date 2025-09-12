// Imports
#import "@preview/brilliant-cv:2.0.6": cv-section, cv-publication
#let metadata = toml("../metadata.toml")
#let cv-section = cv-section.with(metadata: metadata)


#cv-section("Veröffentlichungen")

#cv-publication(
  bib: bibliography("../src/publications.bib"),
  key-list: (
    "smith2020",
    "jones2021",
    "wilson2022",
  ),
  ref-style: "apa",
)
