// Imports
#import "@preview/brilliant-cv:4.1.1": cv-entry, cv-section, h-bar


#cv-section("Abschlüsse")

#cv-entry(
  title: [Master of Data Science],
  society: [Aurora State University],
  date: [2015 - 2017],
  location: [Aurora, WA],
  logo: image(
    "../assets/logos/aurora_state.png",
    alt: "Logo Aurora State University",
  ),
  description: list(
    [Dissertation: Vorhersage der Kundenabwanderung in der Telekommunikationsbranche mit Hilfe von Algorithmen des maschinellen Lernens und Netzwerkanalyse],
    [Kurs: Big-Data-Systeme und -Technologien #h-bar() Data Mining und Exploration #h-bar() Natural Language Processing],
  ),
)

#cv-entry(
  title: [Bachelors of Science in Informatik],
  society: [Aurora State University],
  date: [2011 - 2015],
  location: [Aurora, WA],
  logo: image(
    "../assets/logos/aurora_state.png",
    alt: "Logo Aurora State University",
  ),
  description: list(
    [Dissertation: Erforschung des Einsatzes von Algorithmen des maschinellen Lernens zur Vorhersage von Aktienkursen: Eine vergleichende Studie von Regressions- und Zeitreihenmodellen],
    [Kurs: Datenbanksysteme #h-bar() Rechnernetze #h-bar() Softwaretechnik #h-bar() Künstliche Intelligenz],
  ),
)
