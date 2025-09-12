// Imports
#import "@preview/brilliant-cv:2.0.6": cv-section, cv-skill, h-bar
#let metadata = toml("../metadata.toml")
#let cv-section = cv-section.with(metadata: metadata)


#cv-section("Skills")

#cv-skill(
  type: [Languages],
  info: [English #h-bar() French #h-bar() Chinese],
)

#cv-skill(
  type: [Tech Stack],
  info: [Tableau #h-bar() Python (Pandas/Numpy) #h-bar() PostgreSQL],
)

#cv-skill(
  type: [Personal Interests],
  info: [Swimming #h-bar() Cooking #h-bar() Reading],
)
