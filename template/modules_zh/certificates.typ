// Imports
#import "@preview/brilliant-cv:2.0.6": cv-section, cv-honor
#let metadata = toml("../metadata.toml")
#let cv-section = cv-section.with(metadata: metadata)
#let cv-honor = cv-honor.with(metadata: metadata)


#cv-section("证书")

#cv-honor(
  date: [2022],
  title: [AWS 安全认证],
  issuer: [亚马逊网络服务 (AWS)],
)

#cv-honor(
  date: [2017],
  title: [应用数据科学与 Python],
  issuer: [Coursera],
)

#cv-honor(
  date: [],
  title: [SQL 基础课程],
  issuer: [Datacamp],
)
