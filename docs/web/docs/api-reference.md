# API Reference

## Entry Point Functions

### `cv()`

Render a CV document with header, footer, and page layout applied.

```typ
#cv(metadata, doc, profile-photo: image("avatar.png"), custom-icons: (:))
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `metadata` | dictionary | *required* | The metadata dictionary read from `metadata.toml` |
| `doc` | content | *required* | The body content of the CV (typically the imported modules) |
| `profile-photo` | image | `image("avatar.png")` | The profile photo to display in the header. Pass `none` to hide |
| `custom-icons` | dictionary | `(:)` | Custom icons to override or extend the default icon set |

### `letter()`

Render a cover letter document with header, footer, and page layout applied.

```typ
#letter(
  metadata,
  doc,
  sender-address: "Your Address Here",
  recipient-name: "Company Name Here",
  recipient-address: "Company Address Here",
  date: datetime.today().display(),
  subject: "Subject: Hey!",
  signature: "",
)
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `metadata` | dictionary | *required* | The metadata dictionary read from `metadata.toml` |
| `doc` | content | *required* | The body content of the letter |
| `sender-address` | str | `"Your Address Here"` | The sender's mailing address |
| `recipient-name` | str | `"Company Name Here"` | The recipient's name or company |
| `recipient-address` | str | `"Company Address Here"` | The recipient's mailing address |
| `date` | str | today's date | The date displayed in the letter header |
| `subject` | str | `"Subject: Hey!"` | The subject line of the letter |
| `signature` | str \| content | `""` | Path to a signature image, or content to display as signature |

---

## CV Components

### `cv-section(title)`

Add the title of a section.

The first `letters` characters of the title are highlighted in the accent color, while the rest is rendered in black. For non-Latin languages (zh, ja, ko, ru), highlighting is skipped entirely and the full title is shown in the accent color.

```typ
#cv-section("Professional Experience")
#cv-section("Skills", highlighted: false)
#cv-section("Education", letters: 4)
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `title` | str | *required* | The title of the section |
| `highlighted` | bool | `true` | Whether the first N letters are highlighted in accent color |
| `letters` | int | `3` | Number of first letters to highlight |
| `color` | color | `none` | Override accent color for this section |

### `cv-entry()`

Add an entry to the CV.

When `display_entry_society_first = true` in `metadata.toml`, the `society` field appears bold/first and `title` appears as the subtitle. When `false`, the `title` field is bold/first.

```typ
#cv-entry(
  title: [Data Analyst],
  society: [ABC Company],
  logo: image("assets/logos/abc.png"),
  date: [2017 - 2020],
  location: [New York, NY],
  description: list(
    [Analyzed datasets with SQL and Python],
  ),
  tags: ("Python", "SQL"),
)
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `title` | str | `"Title"` | The title of the entry (role or position) |
| `society` | str | `"Society"` | The society (company, university, etc.) |
| `date` | str \| content | `"Date"` | The date(s) of the entry |
| `location` | str | `"Location"` | The location of the entry |
| `description` | str \| array | `""` | The description. Can be a string or `list(...)` |
| `logo` | image | `""` | The logo of the society. If empty, no logo is displayed |
| `tags` | array | `()` | Tags displayed as chips below the entry |
| `color` | color | `none` | Override the accent color for this entry |

### `cv-entry-start()`

Add the start of a multi-role entry. Use together with `cv-entry-continued` to list multiple roles at the same company.

!!! warning
    Requires `display_entry_society_first = true` in `metadata.toml`.

```typ
#cv-entry-start(
  society: [XYZ Corporation],
  logo: image("assets/logos/xyz.png"),
  location: [San Francisco, CA],
)
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `society` | str | `"Society"` | The society (company, university, etc.) |
| `location` | str | `"Location"` | The location |
| `logo` | image | `""` | The logo of the society |
| `color` | color | `none` | Override the accent color |

### `cv-entry-continued()`

Add a continued entry (additional role) after a `cv-entry-start`. Multiple `cv-entry-continued` calls can follow a single `cv-entry-start`.

```typ
#cv-entry-continued(
  title: [Data Scientist],
  date: [2017 - 2020],
  description: list([Analyzed large datasets...]),
  tags: ("Python", "SQL"),
)
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `title` | str | `"Title"` | The title (role or position) |
| `date` | str \| content | `"Date"` | The date(s) |
| `description` | str \| array | `""` | The description |
| `tags` | array | `()` | Tags displayed as chips |
| `color` | color | `none` | Override the accent color |

### `cv-skill()`

Add a skill row to the CV.

```typ
#cv-skill(
  type: [Tech Stack],
  info: [Python #h-bar() SQL #h-bar() Tableau],
)
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `type` | str | `"Type"` | The skill category (displayed on the left) |
| `info` | str \| content | `"Info"` | The skill details (displayed on the right). Use `#h-bar()` to separate items |

### `cv-skill-with-level()`

Add a skill row with a proficiency level indicator.

The level is rendered as a row of 5 circles: filled circles for the skill level and empty circles for the remainder.

```typ
#cv-skill-with-level(
  type: [Languages],
  level: 4,
  info: [English #h-bar() French #h-bar() Chinese],
)
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `type` | str | `"Type"` | The skill category |
| `level` | int | `3` | The level (0–5), rendered as filled/empty circles |
| `info` | str \| content | `"Info"` | The skill details |

### `cv-skill-tag()`

Add an inline skill tag (chip).

```typ
#cv-skill-tag([AWS Certified])
#cv-skill-tag([Python])
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `skill` | str \| content | *required* | The skill to display |

### `cv-honor()`

Add a honor/certification entry to the CV.

```typ
#cv-honor(
  date: [2022],
  title: [AWS Certified Security],
  issuer: [Amazon Web Services],
  url: "https://aws.amazon.com/certification/",
  location: [Online],
)
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `date` | str | `"1990"` | The date of the honor |
| `title` | str | `"Title"` | The title of the honor |
| `issuer` | str | `""` | The issuer |
| `url` | str | `""` | URL to link the title to |
| `location` | str | `""` | The location |
| `color` | color | `none` | Override the accent color |

### `cv-publication()`

Add publications to the CV by reading a bib file.

```typ
#cv-publication(
  bib: bibliography("assets/publications.bib"),
  key-list: ("smith2020", "jones2021"),
  ref-style: "ieee",
  ref-full: false,
)
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `bib` | bibliography | `""` | The `bibliography` object with the path to the bib file |
| `key-list` | list | `()` | Bib keys to include when `ref-full` is `false` |
| `ref-style` | str | `"apa"` | The reference style (e.g. `"apa"`, `"ieee"`) |
| `ref-full` | bool | `true` | Show all entries (`true`) or only those in `key-list` (`false`) |

---

## Utility Functions

### `h-bar()`

Renders a vertical bar separator (`|`) for use inside skill entries.

```typ
#import "@preview/brilliant-cv:3.0.0": h-bar

[Python #h-bar() SQL #h-bar() Tableau]
```
