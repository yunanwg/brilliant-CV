// Imports
#import "@preview/brilliant-cv:2.0.6": cv-section, cv-entry
#let metadata = toml("../metadata.toml")
#let cv-section = cv-section.with(metadata: metadata)
#let cv-entry = cv-entry.with(metadata: metadata)


#cv-section("Projets & Associations")

#cv-entry(
  title: [Analyste de Données Bénévole],
  society: [ABC Organisation à But Non Lucratif],
  date: [2019 - Présent],
  location: [New York, NY],
  description: list(
    [Analyser les données de donateurs et de collecte de fonds pour identifier les tendances et les opportunités de croissance],
    [Créer des visualisations de données et des tableaux de bord pour communiquer des insights au conseil d'administration],
  ),
)
