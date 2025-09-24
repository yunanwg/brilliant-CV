// Imports
#import "@preview/brilliant-cv:3.0.0": cv-section, cv-entry
#let metadata = toml("../metadata.toml")
#let cv-section = cv-section.with(metadata: metadata)
#let cv-entry = cv-entry.with(metadata: metadata)


#cv-section("Progetti")

#cv-entry(
  title: [Data Analyst volontario],
  society: [ABC Nonprofit Organization],
  date: [2019 - Present],
  location: [New York, NY],
  description: list(
    [Analizzo i dati sui donatori e sulla raccolta fondi per identificare tendenze e opportunità di crescita],
    [Creo visualizzazioni di dati e dashboard per comunicare informazioni al consiglio di amministrazione],
    [Collaboro con altri volontari per sviluppare e implementare strategie basate sui dati],
  ),
)
