// Import
#import "@preview/brilliant-cv:2.0.6": cv-section, cv-skill, h-bar
#let metadata = toml("../metadata.toml")
#let cv-section = cv-section.with(metadata: metadata)


#cv-section("技能与兴趣")

#cv-skill(
  type: [语言],
  info: [英语 #h-bar() 法语 #h-bar() 中文],
)

#cv-skill(
  type: [技术栈],
  info: [Tableau #h-bar() Python (Pandas/Numpy) #h-bar() PostgreSQL],
)

#cv-skill(
  type: [个人兴趣],
  info: [游泳 #h-bar() 烹饪 #h-bar() 阅读],
)
