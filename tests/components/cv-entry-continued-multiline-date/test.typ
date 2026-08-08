// Regression: in the multi-line-date branch of cv-entry-continued (a date
// containing linebreak()), the description was rendered once inside the left
// table cell AND unconditionally a second time after the table — the shipped
// profile_en "Data Scientist" example printed both bullets twice. This pins
// the layout: description exactly once, side by side with the stacked dates.

#import "/src/cv.typ": cv-entry-continued, cv-metadata
#import "/src/utils/styles.typ": _regular-colors
#import "/tests/common.typ": minimal-metadata, test-font-list

#set page(width: 16cm, height: auto, margin: 0.5cm)
#set text(font: test-font-list, size: 9pt, fill: _regular-colors.lightgray)

#cv-metadata.update(_ => minimal-metadata)

#cv-entry-continued(
  title: [Data Scientist],
  date: [2017 - 2020 #linebreak() 2021 - 2022],
  description: list(
    [Analyzed large datasets with SQL and Python.],
    [Built dashboards and maintained data pipelines.],
  ),
  tags: ("SQL", "Python"),
)
