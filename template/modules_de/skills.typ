// Imports
#import "@preview/brilliant-cv:2.0.6": cv-section, cv-skill, h-bar
#let metadata = toml("../metadata.toml")
#let cv-section = cv-section.with(metadata: metadata)


#cv-section("Fähigkeiten")

#cv-skill(
  type: [Sprachen],
  info: [Englisch #h-bar() Französisch #h-bar() Chinesisch],
)

#cv-skill(
  type: [Technologie Stack],
  info: [Tableau #h-bar() Python (Pandas/Numpy) #h-bar() PostgreSQL],
)

#cv-skill(
  type: [Persönliche Interessen],
  info: [Schwimmen #h-bar() Kochen #h-bar() Lesen],
)
