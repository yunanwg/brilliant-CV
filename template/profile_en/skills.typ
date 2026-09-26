// Imports
#import "@preview/brilliant-cv:4.1.1": (
  cv-section, cv-skill, cv-skill-tag, cv-skill-with-level, h-bar,
)


#cv-section("Skills")

#cv-skill(
  type: [Languages],
  info: [English (Native) #h-bar() French (Fluent) #h-bar() Chinese (Conversational)],
)

#cv-skill-with-level(
  type: [Programming],
  level: 5,
  info: [Python #h-bar() SQL #h-bar() R],
)

#cv-skill(
  type: [Tech Stack],
  info: [Tableau #h-bar() Snowflake #h-bar() AWS #h-bar() Docker #h-bar() Git],
)

#cv-skill(
  type: [Frameworks & Libraries],
  info: [Pandas #h-bar() NumPy #h-bar() Scikit-learn #h-bar() TensorFlow #h-bar() FastAPI],
)

// Skill tags example
#cv-skill(
  type: [Certifications],
  info: [
    #cv-skill-tag([AWS Security])
    #cv-skill-tag([Tableau Desktop])
    #cv-skill-tag([Applied Data Science])
    #cv-skill-tag([SQL Fundamentals])
  ],
)

#cv-skill(
  type: [Personal Interests],
  info: [Swimming #h-bar() Cooking #h-bar() Reading #h-bar() Photography],
)
