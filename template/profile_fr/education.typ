// Imports
#import "@preview/brilliant-cv:4.1.1": cv-entry, cv-section, h-bar


#cv-section("Formation")

#cv-entry(
  title: [Master en Science des Données],
  society: [Université d'État d'Aurora],
  date: [2015 - 2017],
  location: [Aurora, WA],
  logo: image(
    "../assets/logos/aurora_state.png",
    alt: "Logo Université d'État d'Aurora",
  ),
  description: list(
    [Thèse : Prédiction du taux de désabonnement des clients dans l'industrie des télécommunications en utilisant des algorithmes d'apprentissage automatique et l'analyse de réseau],
    [Cours : Systèmes et technologies Big Data #h-bar() Exploration et exploitation de données #h-bar() Traitement du langage naturel],
  ),
)

#cv-entry(
  title: [Bachelors en Informatique],
  society: [Université d'État d'Aurora],
  date: [2011 - 2015],
  location: [Aurora, WA],
  logo: image(
    "../assets/logos/aurora_state.png",
    alt: "Logo Université d'État d'Aurora",
  ),
  description: list(
    [Thèse : Exploration de l'utilisation des algorithmes d'apprentissage automatique pour la prédiction des prix des actions : une étude comparative des modèles de régression et de séries chronologiques],
    [Cours : Systèmes de base de données #h-bar() Réseaux informatiques #h-bar() Génie logiciel #h-bar() Intelligence artificielle],
  ),
)
