# Component Gallery

These are the building blocks of your CV.

## cv-section

```typ
#cv-section("Professional Experience")
#cv-section("Skills", highlighted: false)
#cv-section("Education", letters: 4)
```

The section title has its first N letters highlighted in the accent color. Non-Latin languages highlight the full title.

## cv-entry

```typ
#cv-entry(
  title: [Data Analyst],
  society: [ABC Company],
  logo: image("assets/logos/abc.png"),
  date: [2017 - 2020],
  location: [New York, NY],
  description: list(
    [Analyzed datasets with SQL and Python],
    [Created dashboards in Tableau],
  ),
  tags: ("Python", "SQL", "Tableau"),
)
```

!!! tip
    When `display_entry_society_first = true` in `metadata.toml`, the company name appears bold on top and the role appears below.

## Multiple Roles at One Company

Use `cv-entry-start` + `cv-entry-continued` when someone held multiple positions at the same company.

```typ
#cv-entry-start(
  society: [XYZ Corporation],
  logo: image("assets/logos/xyz.png"),
  location: [San Francisco, CA],
)

#cv-entry-continued(
  title: [Director of Data Science],
  description: list([Lead a team of data scientists...]),
  tags: ("Dataiku", "Snowflake"),
)

#cv-entry-continued(
  title: [Data Scientist],
  date: [2017 - 2020],
  description: list([Analyzed large datasets...]),
)
```

!!! warning
    Requires `display_entry_society_first = true` in `metadata.toml`.

## cv-skill and cv-skill-with-level

```typ
#cv-skill(
  type: [Tech Stack],
  info: [Tableau #h-bar() Snowflake #h-bar() AWS],
)

#cv-skill-with-level(
  type: [Languages],
  level: 4,
  info: [English #h-bar() French #h-bar() Chinese],
)
```

Use `#h-bar()` to separate items with a vertical bar. Level is 0–5, rendered as filled/empty circles.

## cv-skill-tag

```typ
#cv-skill(
  type: [Certifications],
  info: [
    #cv-skill-tag([AWS Certified])
    #cv-skill-tag([Google Analytics])
  ],
)
```

## cv-honor

```typ
#cv-honor(
  date: [2022],
  title: [AWS Certified Security],
  issuer: [Amazon Web Services],
  url: "https://aws.amazon.com/certification/",
  location: [Online],
)
```

## cv-publication

```typ
#cv-publication(
  bib: bibliography("assets/publications.bib"),
  key-list: ("smith2020", "jones2021"),
  ref-style: "ieee",
  ref-full: false,
)
```

Set `ref-full: true` to show all entries from the bib file. Set `ref-full: false` and provide `key-list` to show only selected publications.
