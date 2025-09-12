// Imports
#import "@preview/brilliant-cv:2.0.6": cv-section, cv-entry
#let metadata = toml("../metadata.toml")
#let cv-section = cv-section.with(metadata: metadata)
#let cv-entry = cv-entry.with(metadata: metadata)


#cv-section("Projects & Associations")

#cv-entry(
  title: [Volunteer Data Analyst],
  society: [ABC Nonprofit Organization],
  date: [2019 - Present],
  location: [New York, NY],
  description: list(
    [Analyze donor and fundraising data to identify trends and opportunities for growth],
    [Create data visualizations and dashboards to communicate insights to the board of directors],
    [Collaborate with other volunteers to develop and implement data-driven strategies],
  ),
)
