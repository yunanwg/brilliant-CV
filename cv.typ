/*
* Functions for the CV template
*/

#import "@preview/fontawesome:0.6.0": *
#import "./utils/injection.typ": _inject
#import "./utils/styles.typ": _latin-font-list, _latin-header-font, _awesome-colors, _regular-colors, _set-accent-color, h-bar
#import "./utils/lang.typ": _is-non-latin, _default-date-width

/// Insert the header section of the CV.
///
/// - metadata (array): the metadata read from the TOML file.
/// - header-font (array): the font of the header.
/// - regular-colors (array): the regular colors of the CV.
/// - awesome-colors (array): the awesome colors of the CV.
/// -> content
#let _cvHeader(
  metadata,
  profile-photo,
  header-font,
  regular-colors,
  awesome-colors,
) = {
  // Parameters
  let header-alignment = eval(metadata.layout.header.header_align)
  let inject-ai-prompt = metadata.inject.inject_ai_prompt
  let inject-keywords = metadata.inject.inject_keywords
  let keywords = metadata.inject.injected_keywords_list
  let personal-info = metadata.personal.info
  let first-name = metadata.personal.first_name
  let last-name = metadata.personal.last_name
  let header-quote = metadata.lang.at(metadata.language).at("header_quote", default: none)
  let display-profile-photo = metadata.layout.header.display_profile_photo
  let profile-photo-radius = eval(metadata.layout.header.at("profile_photo_radius", default: "50%"))
  let header-info-font-size = eval(metadata.layout.header.at("info_font_size", default: "10pt"))
  let accent-color = _set-accent-color(_awesome-colors, metadata)
  let non-latin-name = ""
  let non-latin = _is-non-latin(metadata.language)
  if non-latin {
    non-latin-name = metadata.lang.non_latin.name
  }

  // Injection
  _inject(
    inject-ai-prompt: inject-ai-prompt,
    inject-keywords: inject-keywords,
    keywords: keywords,
  )

  // Styles
  let header-first-name-style(str) = {
    text(
      font: header-font,
      size: 32pt,
      weight: "light",
      fill: regular-colors.darkgray,
      str,
    )
  }
  let header-last-name-style(str) = {
    text(font: header-font, size: 32pt, weight: "bold", str)
  }
  let header-info-style(str) = {
    text(size: header-info-font-size, fill: accent-color, str)
  }
  let header-quote-style(str) = {
    text(size: 10pt, weight: "medium", style: "italic", fill: accent-color, str)
  }

  // Components
  let make-header-info() = {
    let personal-info-icons = (
      phone: fa-phone(),
      email: fa-envelope(),
      linkedin: fa-linkedin(),
      homepage: fa-pager(),
      github: fa-square-github(),
      gitlab: fa-gitlab(),
      orcid: fa-orcid(),
      researchgate: fa-researchgate(),
      location: fa-location-dot(),
      extraInfo: "",
    )
    let n = 1
    for (k, v) in personal-info {
      // A dirty trick to add linebreaks with "linebreak" as key in personalInfo
      if k == "linebreak" {
        n = 0
        linebreak()
        continue
      }
      if k.contains("custom") {
        let img = v.at("image", default: "")
        let awesome-icon = v.at("awesomeIcon", default: "")
        let text = v.at("text", default: "")
        let link-value = v.at("link", default: "")
        let icon = ""
        if img != "" {
          icon = img.with(width: 10pt)
        } else {
          icon = fa-icon(awesome-icon)
        }
        box({
          icon
          h(5pt)
          if link-value != "" {
            link(link-value)[#text]
          } else {
            text
          }
        })
      } else if v != "" {
        box({
          // Adds icons
          personal-info-icons.at(k)
          h(5pt)
          // Adds hyperlinks
          if k == "email" {
            link("mailto:" + v)[#v]
          } else if k == "linkedin" {
            link("https://www.linkedin.com/in/" + v)[#v]
          } else if k == "github" {
            link("https://github.com/" + v)[#v]
          } else if k == "gitlab" {
            link("https://gitlab.com/" + v)[#v]
          } else if k == "homepage" {
            link("https://" + v)[#v]
          } else if k == "orcid" {
            link("https://orcid.org/" + v)[#v]
          } else if k == "researchgate" {
            link("https://www.researchgate.net/profile/" + v)[#v]
          } else if k == "phone" {
            link("tel:" + v.replace(" ",""))[#v]
          } else {
            v
          }
        })
      }
      // Adds hBar
      if n != personal-info.len() {
        h-bar()
      }
      n = n + 1
    }
  }

  let make-header-name-section() = table(
    columns: 1fr,
    inset: 0pt,
    stroke: none,
    row-gutter: 6mm,
    if non-latin {
      header-first-name-style(non-latin-name)
    } else [#header-first-name-style(first-name) #h(5pt) #header-last-name-style(last-name)],
    [#header-info-style(make-header-info())],
    .. if header-quote != none { ([#header-quote-style(header-quote)],) },
  )

  let make-header-photo-section(
    display-profile-photo: display-profile-photo,
    profile-photo: profile-photo,
    profile-photo-radius: profile-photo-radius,
  ) = {
    set image(height: 3.6cm)
    if display-profile-photo {
      box(profile-photo, radius: profile-photo-radius, clip: true)
    } else {
      v(3.6cm)
    }
  }

  let make-header(contents, columns, align) = table(
    columns: columns,
    inset: 0pt,
    stroke: none,
    column-gutter: 15pt,
    align: align + horizon,
    ..contents,
  )

  if display-profile-photo {
    make-header(
      (make-header-name-section(), make-header-photo-section()),
      (auto, 20%),
      header-alignment,
    )
  } else {
    make-header(
      (make-header-name-section()),
      (auto),
      header-alignment,
    )
  }
}

/// Insert the footer section of the CV.
///
/// - metadata (array): the metadata read from the TOML file.
/// -> content
#let _cv-footer(metadata) = {
  // Parameters
  let first-name = metadata.personal.first_name
  let last-name = metadata.personal.last_name
  let footer-text = metadata.lang.at(metadata.language).cv_footer
  let display-page-counter = metadata.layout.at("footer", default: {}).at("display_page_counter", default: false)
  let display-footer = metadata.layout.at("footer", default: {}).at("display_footer", default: true)

  if not display-footer {
    return none
  }

  // Styles
  let footer-style(str) = {
    text(size: 8pt, fill: rgb("#999999"), smallcaps(str))
  }

  return if display-page-counter {
    table(
      columns: (1fr, 1fr, 1fr),
      inset: -5pt,
      stroke: none,
      align(left, footer-style([#first-name #last-name])),
      align(center, footer-style(footer-text)),
      align(right, footer-style(counter(page).display())),
    )
  } else {
    table(
      columns: (1fr, auto),
      inset: -5pt,
      stroke: none,
      footer-style([#first-name #last-name]),
      footer-style(footer-text),
    )
  }

}

/// Add the title of a section.
///
/// NOTE: If the language is non-Latin, the title highlight will not be sliced.
///
/// - title (str): The title of the section.
/// - highlighted (bool): Whether the first n letters will be highlighted in accent color.
/// - letters (int): The number of first letters of the title to highlight.
/// - metadata (array): (optional) the metadata read from the TOML file.
/// - awesome-colors (array): (optional) the awesome colors of the CV.
/// -> content
#let cv-section(
  title,
  highlighted: true,
  letters: 3,
  metadata: metadata,
  awesome-colors: _awesome-colors,
) = {
  let lang = metadata.language
  let non-latin = _is-non-latin(lang)
  let before-section-skip = eval(
    metadata.layout.at("before_section_skip", default: 1pt),
  )
  let accent-color = _set-accent-color(awesome-colors, metadata)
  let highlighted-text = title.slice(0, letters)
  let normal-text = title.slice(letters)

  let section-title-style(str, color: black) = {
    text(size: 16pt, weight: "bold", fill: color, str)
  }

  v(before-section-skip)
  if non-latin {
    section-title-style(title, color: accent-color)
  } else {
    if highlighted {
      section-title-style(highlighted-text, color: accent-color)
      section-title-style(normal-text, color: black)
    } else {
      section-title-style(title, color: black)
    }
  }
  h(2pt)
  box(width: 1fr, line(stroke: 0.9pt, length: 100%))
}

/// Add an entry to the CV.
///
/// - title (str): The title of the entry.
/// - society (str): The society of the entry (company, university, etc.).
/// - date (str | content): The date(s) of the entry.
/// - location (str): The location of the entry.
/// - description (array): The description of the entry. It can be a string or an array of strings.
/// - logo (image): The logo of the society. If empty, no logo will be displayed.
/// - tags (array): The tags of the entry.
/// - metadata (array): (optional) the metadata read from the TOML file.
/// - awesome-colors (array): (optional) the awesome colors of the CV.
/// -> content
#let cv-entry(
  title: "Title",
  society: "Society",
  date: "Date",
  location: "Location",
  description: "Description",
  logo: "",
  tags: (),
  metadata: metadata,
  awesome-colors: _awesome-colors,
) = {
  let accent-color = _set-accent-color(awesome-colors, metadata)
  let before-entry-skip = eval(
    metadata.layout.at("before_entry_skip", default: 1pt),
  )
  let before-entry-description-skip = eval(
    metadata.layout.at("before_entry_description_skip", default: 1pt),
  )
  let date-width = metadata.layout.at("date_width", default: none)
  let date-width = if date-width == none {
    _default-date-width(metadata.language)
  } else {
    eval(date-width)
  }

  let entry-a1-style(str) = {
    text(size: 10pt, weight: "bold", str)
  }
  let entry-a2-style(str) = {
    align(
      right,
      text(weight: "medium", fill: accent-color, style: "oblique", str),
    )
  }
  let entry-b1-style(str) = {
    text(size: 8pt, fill: accent-color, weight: "medium", smallcaps(str))
  }
  let entry-b2-style(str) = {
    align(
      right,
      text(size: 8pt, weight: "medium", fill: gray, style: "oblique", str),
    )
  }
  let entry-dates-style(dates) = {
    [
      #set list(marker: [])
      #dates
    ]
  }
  let entry-description-style(str) = {
    text(
      fill: _regular-colors.lightgray,
      {
        v(before-entry-description-skip)
        str
      },
    )
  }
  let entry-tag-style(str) = {
    align(center, text(size: 8pt, weight: "regular", str))
  }
  let entry-tag-list-style(tags) = {
    for tag in tags {
      box(
        inset: (x: 0.25em),
        outset: (y: 0.25em),
        fill: _regular-colors.subtlegray,
        radius: 3pt,
        entry-tag-style(tag),
      )
      h(5pt)
    }
  }

  let society-first(condition, field-1, field-2) = {
    return if condition {
      field-1
    } else {
      field-2
    }
  }
  let display-society-logo(path, if-true, if-false) = {
    return if metadata.layout.entry.display_logo {
      if path == "" {
        if-false
      } else {
        if-true
      }
    } else {
      if-false
    }
  }
  let set-logo-content(path) = {
    return if logo == "" [] else {
      set image(width: 100%)
      logo
    }
  }

  v(before-entry-skip)
  table(
    columns: (1fr, date-width),
    inset: 0pt,
    stroke: none,
    gutter: 6pt,
    align: (x, y) => if x == 1 { right } else { auto },
    table(
      columns: (display-society-logo(logo, 4%, 0%), 1fr),
      inset: 0pt,
      stroke: none,
      align: horizon,
      column-gutter: display-society-logo(logo, 4pt, 0pt),
      set-logo-content(logo),
      table(
        columns: auto,
        inset: 0pt,
        stroke: none,
        row-gutter: 6pt,
        align: auto,
        {
          entry-a1-style(
            society-first(
              metadata.layout.entry.display_entry_society_first,
              society,
              title,
            ),
          )
        },

        {
          entry-b1-style(
            society-first(
              metadata.layout.entry.display_entry_society_first,
              title,
              society,
            ),
          )
        },
      ),
    ),
    table(
      columns: auto,
      inset: 0pt,
      stroke: none,
      row-gutter: 6pt,
      align: auto,
      entry-a2-style(
        society-first(
          metadata.layout.entry.display_entry_society_first,
          location,
          entry-dates-style(date),
        ),
      ),
      entry-b2-style(
        society-first(
          metadata.layout.entry.display_entry_society_first,
          entry-dates-style(date),
          location,
        ),
      ),
    ),
  )
  entry-description-style(description)
  entry-tag-list-style(tags)
}

/// Add the start of an entry to the CV.
///
/// - society (str): The society of the entry (company, university, etc.).
/// - location (str): The location of the entry.
/// - logo (image): The logo of the society. If empty, no logo will be displayed.
/// - metadata (array): (optional) the metadata read from the TOML file.
/// - awesome-colors (array): (optional) the awesome colors of the CV.
/// -> content
#let cv-entry-start(
  society: "Society",
  location: "Location",
  logo: "",
  metadata: metadata,
  awesome-colors: _awesome-colors,
) = {
  // To use cvEntryStart, you need to set display_entry_society_first to true in the metadata.toml file.
  if not metadata.layout.entry.display_entry_society_first {
    panic("display_entry_society_first must be true to use cvEntryStart")
  }

  let accent-color = _set-accent-color(awesome-colors, metadata)
  let before-entry-skip = eval(
    metadata.layout.at("before_entry_skip", default: 1pt),
  )
  let before-entry-description-skip = eval(
    metadata.layout.at("before_entry_description_skip", default: 1pt),
  )
  let date-width = metadata.layout.at("date_width", default: none)
  let date-width = if date-width == none {
    _default-date-width(metadata.language)
  } else {
    eval(date-width)
  }
  
  let entry-a1-style(str) = {
    text(size: 10pt, weight: "bold", str)
  }
  let entry-a2-style(str) = {
    align(
      right,
      text(weight: "medium", fill: accent-color, style: "oblique", str),
    )
  }
  let entry-dates-style(dates) = {
    [
      #set list(marker: [])
      #dates
    ]
  }
  let entry-description-style(str) = {
    text(
      fill: _regular-colors.lightgray,
      {
        v(before-entry-description-skip)
        str
      },
    )
  }
  let entry-tag-style(str) = {
    align(center, text(size: 8pt, weight: "regular", str))
  }
  let entry-tag-list-style(tags) = {
    for tag in tags {
      box(
        inset: (x: 0.25em),
        outset: (y: 0.25em),
        fill: _regular-colors.subtlegray,
        radius: 3pt,
        entry-tag-style(tag),
      )
      h(5pt)
    }
  }

  let display-society-first(condition, field1, field2) = {
    return if condition {
      field1
    } else {
      field2
    }
  }
  let display-society-logo(path, ifTrue, ifFalse) = {
    return if metadata.layout.entry.display_logo {
      if path == "" {
        ifFalse
      } else {
        ifTrue
      }
    } else {
      ifFalse
    }
  }
  let set-logo-content(path) = {
    return if logo == "" [] else {
      set image(width: 100%)
      logo
    }
  }

  v(before-entry-skip)
  table(
    columns: (display-society-logo(logo, 4%, 0%), 1fr, date-width),
    inset: 0pt,
    stroke: none,
    gutter: 6pt,
    align: horizon,
    set-logo-content(logo),
    entry-a1-style(society),
    entry-a2-style(location),
  )
  v(-10pt)
}

/// Add a continued entry to the CV.
///
/// - title (str): The title of the entry.
/// - date (str | content): The date(s) of the entry.
/// - description (array): The description of the entry. It can be a string or an array of strings.
/// - tags (array): The tags of the entry.
/// - metadata (array): (optional) the metadata read from the TOML file.
/// - awesome-colors (array): (optional) the awesome colors of the CV.
/// -> content
#let cv-entry-continued(
  title: "Title",
  date: "Date",
  description: "Description",
  tags: (),
  metadata: metadata,
  awesome-colors: _awesome-colors,
) = {
  // To use cv-entry-continued, you need to set display_entry_society_first to true in the metadata.toml file.
  if not metadata.layout.entry.display_entry_society_first {
    panic("display_entry_society_first must be true to use cvEntryContinued")
  }
  
  let accent-color = _set-accent-color(awesome-colors, metadata)
  let before-entry-skip = eval(
    metadata.layout.at("before_entry_skip", default: 1pt),
  )
  let before-entry-description-skip = eval(
    metadata.layout.at("before_entry_description_skip", default: 1pt),
  )
  let date-width = metadata.layout.at("date_width", default: none)
  let date-width = if date-width == none {
    _default-date-width(metadata.language)
  } else {
    eval(date-width)
  }

  let entry-b1-style(str) = {
    text(size: 8pt, fill: accent-color, weight: "medium", smallcaps(str))
  }
  let entry-b2-style(str) = {
    align(
      right,
      text(size: 8pt, weight: "medium", fill: gray, style: "oblique", str),
    )
  }
  let entry-dates-style(dates) = {
    [
      #set list(marker: [])
      #dates
    ]
  }
  let entry-description-style(str) = {
    text(
      fill: _regular-colors.lightgray,
      {
        v(before-entry-description-skip)
        str
      },
    )
  }
  let entry-tag-style(str) = {
    align(center, text(size: 8pt, weight: "regular", str))
  }
  let entry-tag-list-style(tags) = {
    for tag in tags {
      box(
        inset: (x: 0.25em),
        outset: (y: 0.25em),
        fill: _regular-colors.subtlegray,
        radius: 3pt,
        entry-tag-style(tag),
      )
      h(5pt)
    }
  }

  // If the date contains a linebreak, use legacy side-to-side layout
  let multiple-dates
  if type(date) == content {
    multiple-dates = if linebreak() in date.fields().children { true } else { false }
  } else {
    multiple-dates = false
  }

  v(before-entry-skip)
  if not multiple-dates {
    table(
      columns: (1fr, date-width),
      inset: 0pt,
      stroke: none,
      gutter: 6pt,
      align: auto,
      {
        entry-b1-style(title)
      },
      entry-b2-style(entry-dates-style(date)),
    )
    entry-description-style(description)
    entry-tag-list-style(tags)
  } else {
    table(
      columns: (1fr, date-width),
      inset: 0pt,
      stroke: none,
      gutter: 6pt,
      align: auto,
      {
        entry-b1-style(title)
        entry-description-style(description)
      },
      entry-b2-style(entry-dates-style(date)),
    )
    entry-tag-list-style(tags)
  }
}

/// Add a skill to the CV.
///
/// - type (str): The type of the skill. It is displayed on the left side.
/// - info (str | content): The information about the skill. It is displayed on the right side. Items can be separated by `#hbar()`.
/// -> content
#let cv-skill(type: "Type", info: "Info") = {
  let skill-type-style(str) = {
    align(right, text(size: 10pt, weight: "bold", str))
  }
  let skill-info-style(str) = {
    text(str)
  }

  table(
    columns: (17%, 1fr),
    inset: 0pt,
    column-gutter: 10pt,
    stroke: none,
    skill-type-style(type), skill-info-style(info),
  )
  v(-6pt)
}

/// Add a skill with a level to the CV.
///
/// - type (str): The type of the skill. It is displayed on the left side.
/// - level (int): The level of the skill. It is displayed in as circles in the middle. The minimum level is 0 and the maximum level is 5.
/// - info (str | content): The information about the skill. It is displayed on the right side.
/// -> content
#let cv-skill-with-level(
  type: "Type",
  level: 3,
  info: "Info"
) = {
  let skill-type-style(str) = {
    align(right, text(size: 10pt, weight: "bold", str))
  }
  let skill-info-style(str) = {
    text(str)
  }
  let skill-level-style(str) = {
    set text(size: 10pt, fill: _regular-colors.darkgray)
    for x in range(0, level) {
      [#fa-icon("circle", solid: true) ]
    }
    for x in range(level, 5) {
      [#fa-icon("circle") ]
    }
  }

  table(
    columns: (17%, auto, 1fr),
    inset: 0pt,
    column-gutter: 10pt,
    stroke: none,
    skill-type-style(type), skill-level-style(level), skill-info-style(info),
  )
  v(-6pt)
}

/// Add a skill tag to the CV.
/// 
/// - skill (str | content): The skill to be displayed.
/// -> content
#let cv-skill-tag(skill) = {
  let entry-tag-style(str) = {
    align(center, text(size: 10pt, weight: "regular", str))
  }
  box(
    inset: (x: 0.5em, y: 0.5em),
    fill: _regular-colors.subtlegray,
    radius: 3pt,
    entry-tag-style(skill),
  )
  h(5pt)
}

/// Add a Honor to the CV.
///
/// - date (str): The date of the honor.
/// - title (str): The title of the honor.
/// - issuer (str): The issuer of the honor.
/// - url (str): The URL of the honor.
/// - location (str): The location of the honor.
/// - awesome-colors (array): (optional) The awesome colors of the CV.
/// - metadata (array): (optional) The metadata read from the TOML file.
/// -> content
#let cv-honor(
  date: "1990",
  title: "Title",
  issuer: "",
  url: "",
  location: "",
  awesome-colors: _awesome-colors,
  metadata: metadata,
) = {
  let accent-color = _set-accent-color(awesome-colors, metadata)

  let honor-date-style(str) = {
    align(right, text(str))
  }
  let honor-title-style(str) = {
    text(weight: "bold", str)
  }
  let honor-issuer-style(str) = {
    text(str)
  }
  let honor-location-style(str) = {
    align(
      right,
      text(weight: "medium", fill: accent-color, style: "oblique", str),
    )
  }

  table(
    columns: (16%, 1fr, 15%),
    inset: 0pt,
    column-gutter: 10pt,
    align: horizon,
    stroke: none,
    honor-date-style(date),
    if issuer == "" {
      honor-title-style(title)
    } else if url != "" {
      [
        #honor-title-style(link(url)[#title]), #honor-issuer-style(issuer)
      ]
    } else {
      [
        #honor-title-style(title), #honor-issuer-style(issuer)
      ]
    },
    honor-location-style(location),
  )
  v(-6pt)
}

/// Add the publications to the CV by reading a bib file.
///
/// - bib (bibliography): The `bibliography` object with the path to the bib file.
/// - keyList (list): The list of keys to include in the publication list.
/// - refStyle (str): The reference style of the publication list.
/// - refFull (bool): Whether to show the full reference or not.
/// -> content
#let cv-publication(bib: "", refStyle: "apa", refFull: true, keyList: list()) = {
  let publication-style(str) = {
    text(str)
  }
  show bibliography: it => publication-style(it)
  set bibliography(title: none, style: refStyle, full: refFull)

  if refFull {
    bib
  } else {
    for key in keyList {
      cite(label(key), form: none)
    }
    bib
  }
}

// Backward compatibility
#let cvPublication = cv-publication
#let cvEntryStart = cv-entry-start
#let cvEntryContinued = cv-entry-continued
#let cvSkill = cv-skill
#let cvSkillWithLevel = cv-skill-with-level
#let cvSkillTag = cv-skill-tag
#let cvHonor = cv-honor
#let cvSection = cv-section
#let cvEntry = cv-entry
