// Imports
#import "@preview/brilliant-cv:2.0.6": cv-section, cv-skill, h-bar
#let metadata = toml("../metadata.toml")
#let cv-section = cv-section.with(metadata: metadata)


#cv-section("Competenze")

#cv-skill(
  type: [Lingue],
  info: [Inglese #h-bar() Francese #h-bar() Cinese],
)

#cv-skill(
  type: [Tecnologie],
  info: [Tableau #h-bar() Python (Pandas/Numpy) #h-bar() PostgreSQL],
)

#cv-skill(
  type: [Interessi personali],
  info: [Nuoto #h-bar() Cucina #h-bar() Lettura],
)
