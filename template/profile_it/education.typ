// Imports
#import "@preview/brilliant-cv:4.1.1": cv-entry, cv-section, h-bar


#cv-section("Istruzione")

#cv-entry(
  title: [Master in Data Science],
  society: [Aurora State University],
  date: [2015 - 2017],
  location: [Aurora, WA],
  logo: image(
    "../assets/logos/aurora_state.png",
    alt: "Logo Aurora State University",
  ),
  description: list(
    [Tesi: Previsione del tasso di abbandono dei clienti nel settore delle telecomunicazioni mediante algoritmi di apprendimento automatico e analisi delle reti],
    [Corsi: Sistemi e tecnologie basati su Big Data #h-bar() Data Mining #h-bar() Natural language processing],
  ),
)

#cv-entry(
  title: [Laurea in informatica],
  society: [Aurora State University],
  date: [2011 - 2015],
  location: [Aurora, WA],
  logo: image(
    "../assets/logos/aurora_state.png",
    alt: "Logo Aurora State University",
  ),
  description: list(
    [Tesi: Esplorazione di algoritmi di apprendimento automatico per prevedere i prezzi delle azioni: uno studio comparativo di modelli di regressione e serie temporali],
    [Corsi: Sistemi di database #h-bar() Reti di calcolatori #h-bar() Ingegneria del software #h-bar() Intelligenza artificiale],
  ),
)
