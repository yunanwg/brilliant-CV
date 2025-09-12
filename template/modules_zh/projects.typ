// Imports
#import "@preview/brilliant-cv:2.0.6": cv-section, cv-entry
#let metadata = toml("../metadata.toml")
#let cv-section = cv-section.with(metadata: metadata)
#let cv-entry = cv-entry.with(metadata: metadata)


#cv-section("项目与协会")

#cv-entry(
  title: [志愿数据分析师],
  society: [ABC 非营利组织],
  date: [2019 - 现在],
  location: [纽约, NY],
  description: list(
    [分析捐赠者和筹款数据以识别增长的趋势和机会],
    [创建数据可视化和仪表板以向董事会传达洞见],
  ),
)
