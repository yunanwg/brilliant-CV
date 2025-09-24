// Imports
#import "@preview/brilliant-cv:3.0.0": cv-section, cv-honor
#let metadata = toml("../metadata.toml")
#let cv-section = cv-section.with(metadata: metadata)
#let cv-honor = cv-honor.with(metadata: metadata)


#cv-section("Certificazioni")

#cv-honor(
  date: [2022],
  title: [AWS Certified Security],
  issuer: [Amazon Web Services (AWS)],
)

#cv-honor(
  date: [2017],
  title: [Applied Data Science with Python],
  issuer: [Coursera],
)

#cv-honor(
  date: [],
  title: [Fondamenti di SQL],
  issuer: [Datacamp],
)
