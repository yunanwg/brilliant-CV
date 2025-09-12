// Imports
#import "@preview/brilliant-cv:2.0.6": cv-section, cv-skill, h-bar
#let metadata = toml("../metadata.toml")
#let cv-section = cv-section.with(metadata: metadata)


#cv-section("Compétences")

#cv-skill(
  type: [Langues],
  info: [Anglais #h-bar() Français #h-bar() Chinois],
)

#cv-skill(
  type: [Tech Stack],
  info: [Tableau #h-bar() Python (Pandas/Numpy) #h-bar() PostgreSQL],
)

#cv-skill(
  type: [Centres d'intérêt],
  info: [Natation #h-bar() Cuisine #h-bar() Lecture],
)
