// Imports
#import "@preview/brilliant-cv:2.0.1": cv-section, cv-publication
#let metadata = toml("../metadata.toml")
#let cv-section = cv-section.with(metadata: metadata)

#cv-section("Publications")

#cv-publication(
  bib: bibliography("../src/publications.bib"),
  keyList: ("smith2020", "jones2021", "wilson2022"),
  refStyle: "apa",
)
