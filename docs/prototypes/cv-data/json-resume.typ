// PROTOTYPE — not part of the published package.
//
// Render a JSON Resume (https://jsonresume.org/schema, v1.0.0) document with
// brilliant-cv components, in pure Typst: no converter, no extra tool.
//
//   #let data = json("resume.json")          // or yaml("resume.yaml")
//   #let tailor = yaml("applications/acme.yaml")  // optional
//   #show: cv.with(metadata-from-json-resume(base, data, tailor: tailor))
//   #render-json-resume(data, tailor: tailor)
//
// Facts live in resume.json. A tailor file only *selects and orders* them by
// `id`; an unknown id or an out-of-range highlight index is a compile error,
// so a tailored CV cannot contain a fact that the resume does not hold.
//
// Extensions to the JSON Resume schema (all optional, all allowed by the
// schema's additionalProperties):
//   id           stable reference for tailor files (any section item)
//   displayDate  string or array of strings that replaces the computed period

#import "@preview/brilliant-cv:4.1.1": (
  cv-entry, cv-entry-continued, cv-entry-start, cv-honor, cv-section,
  cv-skill, h-bar,
)

#let default-labels = (
  work: "Professional Experience",
  education: "Education",
  projects: "Projects & Associations",
  volunteer: "Volunteering",
  certificates: "Certificates & Awards",
  skills: "Skills",
  languages: "Languages",
  interests: "Personal Interests",
  courses: "Courses",
  score: "GPA",
  present: "Present",
)

#let default-sections = (
  "education",
  "work",
  "projects",
  "volunteer",
  "certificates",
  "skills",
)

// ---------------------------------------------------------------------------
// Selection

#let _id-of(item) = item.at("id", default: none)

#let _pick-subset(item, field, wanted, kind) = {
  let have = item.at(field, default: ())
  if field == "highlights" {
    for i in wanted {
      if type(i) != int or i < 0 or i >= have.len() {
        panic(
          "tailor: " + kind + " `" + _id-of(item) + "` has no highlight "
            + repr(i) + " (it has " + str(have.len()) + ")",
        )
      }
    }
    wanted.map(i => have.at(i))
  } else {
    for k in wanted {
      if k not in have {
        panic(
          "tailor: " + kind + " `" + _id-of(item) + "` has no " + field
            + " " + repr(k) + ". Known: " + have.map(repr).join(", "),
        )
      }
    }
    wanted
  }
}

/// Keep and order the items of one section as the tailor file lists them.
/// A pick is an id string, or a dictionary with `id` and optional
/// `highlights` (indices) and `keywords` (a subset, in display order).
#let _select(items, picks, kind) = {
  if picks == none { return items }
  picks.map(pick => {
    let opts = if type(pick) == str { (id: pick) } else { pick }
    let found = items.filter(it => _id-of(it) == opts.id)
    if found.len() == 0 {
      let known = items.map(_id-of).filter(it => it != none)
      panic(
        "tailor: unknown " + kind + " id `" + opts.id + "`. Known ids: "
          + known.join(", "),
      )
    }
    let item = found.first()
    for field in ("highlights", "keywords") {
      if field in opts {
        item.insert(field, _pick-subset(item, field, opts.at(field), kind))
      }
    }
    item
  })
}

// ---------------------------------------------------------------------------
// Formatting

#let _year(date) = if date == none { none } else { str(date).slice(0, 4) }

#let _period(item, labels) = {
  if "displayDate" in item {
    let d = item.displayDate
    return if type(d) == array { list(..d.map(it => [#it])) } else { d }
  }
  let start = _year(item.at("startDate", default: none))
  let end-raw = item.at("endDate", default: none)
  let end = if end-raw == none { labels.present } else { _year(end-raw) }
  if start == none { end } else if start == end { start } else [#start - #end]
}

#let _bullets(lines) = if lines.len() == 0 { "" } else {
  list(..lines.map(it => [#it]))
}

#let _joined(words) = words.map(it => [#it]).join(h-bar())

// ---------------------------------------------------------------------------
// Sections

#let _render-work(items, labels, logos) = {
  // Consecutive roles at the same company share one header.
  let groups = ()
  for item in items {
    if groups.len() > 0 and groups.last().first().name == item.name {
      groups.last().push(item)
    } else {
      groups.push((item,))
    }
  }
  for group in groups {
    let first = group.first()
    let logo = logos.at(first.name, default: "")
    let location = first.at("location", default: "")
    if group.len() == 1 {
      cv-entry(
        title: first.position,
        society: first.name,
        logo: logo,
        date: _period(first, labels),
        location: location,
        description: _bullets(first.at("highlights", default: ())),
        tags: first.at("keywords", default: ()),
      )
    } else {
      cv-entry-start(society: first.name, logo: logo, location: location)
      for role in group {
        cv-entry-continued(
          title: role.position,
          date: _period(role, labels),
          description: _bullets(role.at("highlights", default: ())),
          tags: role.at("keywords", default: ()),
        )
      }
    }
  }
}

#let _render-education(items, labels, logos) = {
  for item in items {
    let lines = item.at("highlights", default: ())
    let courses = item.at("courses", default: ())
    if courses.len() > 0 { lines.push([#labels.courses: #_joined(courses)]) }
    if "score" in item { lines.push([#labels.score: #item.score]) }
    cv-entry(
      title: [#item.studyType in #item.area],
      society: item.institution,
      logo: logos.at(item.institution, default: ""),
      date: _period(item, labels),
      location: item.at("location", default: ""),
      description: _bullets(lines),
    )
  }
}

#let _render-projects(items, labels, logos) = {
  for item in items {
    cv-entry(
      title: item.name,
      society: item.at("entity", default: ""),
      date: _period(item, labels),
      location: item.at("location", default: ""),
      description: _bullets(item.at("highlights", default: ())),
      tags: item.at("keywords", default: ()),
    )
  }
}

#let _render-volunteer(items, labels, logos) = {
  for item in items {
    cv-entry(
      title: item.position,
      society: item.organization,
      logo: logos.at(item.organization, default: ""),
      date: _period(item, labels),
      location: item.at("location", default: ""),
      description: _bullets(item.at("highlights", default: ())),
      tags: item.at("keywords", default: ()),
    )
  }
}

#let _render-honors(certificates, awards) = {
  let rows = (
    certificates.map(it => (
      date: _year(it.at("date", default: none)),
      title: it.name,
      issuer: it.at("issuer", default: ""),
      url: it.at("url", default: ""),
    ))
      + awards.map(it => (
        date: _year(it.at("date", default: none)),
        title: it.title,
        issuer: it.at("awarder", default: ""),
        url: "",
      ))
  )
  for row in rows.sorted(key: it => it.date).rev() {
    cv-honor(..row)
  }
}

#let _render-skills(skills, languages, interests, labels) = {
  for skill in skills {
    cv-skill(type: skill.name, info: _joined(skill.at("keywords", default: ())))
  }
  if languages.len() > 0 {
    cv-skill(
      type: labels.languages,
      info: _joined(languages.map(it => it.language + " (" + it.fluency + ")")),
    )
  }
  if interests.len() > 0 {
    cv-skill(type: labels.interests, info: _joined(interests.map(it => it.name)))
  }
}

// ---------------------------------------------------------------------------
// Public entry points

/// Fill `[personal]` and `header_quote` of a brilliant-cv metadata
/// dictionary from `basics`. Layout settings come from `metadata`.
#let metadata-from-json-resume(metadata, data, tailor: none) = {
  let basics = data.basics
  let parts = basics.name.split(" ")
  let info = (:)
  for profile in basics.at("profiles", default: ()) {
    let network = lower(profile.network)
    if network in ("github", "gitlab", "linkedin", "orcid", "researchgate") {
      info.insert(network, profile.username)
    }
  }
  if "email" in basics { info.insert("email", basics.email) }
  if "phone" in basics { info.insert("phone", basics.phone) }
  if "url" in basics {
    info.insert("homepage", basics.url.replace(regex("^https?://"), ""))
  }
  if "location" in basics {
    let loc = basics.location
    let place = (loc.at("city", default: none), loc.at("region", default: none))
    info.insert("location", place.filter(it => it != none).join(", "))
  }

  metadata.personal = metadata.personal + (
    first_name: parts.slice(0, -1).join(" "),
    last_name: parts.last(),
    info: info,
  )
  let quote = if tailor != none and "label" in tailor { tailor.label } else {
    basics.at("label", default: none)
  }
  if quote != none { metadata.insert("header_quote", quote) }
  if tailor != none and "keywords" in tailor {
    metadata.insert("inject", (injected_keywords_list: tailor.keywords))
  }
  metadata
}

/// Render the sections of a JSON Resume document.
///
/// - data (dictionary): the parsed JSON Resume document.
/// - tailor (dictionary | none): optional selection. `sections` lists the
///   sections to show, in order; each section key lists the items to keep,
///   in order (see `_select`).
/// - labels (dictionary): section titles and words, merged over
///   `default-labels`. Translate these for a non-English profile.
/// - logos (dictionary): company or institution name -> image.
#let render-json-resume(data, tailor: none, labels: (:), logos: (:)) = {
  let labels = default-labels + labels
  let tailor = if tailor == none { (:) } else { tailor }
  let section(key) = _select(
    data.at(key, default: ()),
    tailor.at(key, default: none),
    key,
  )

  for key in tailor.at("sections", default: default-sections) {
    if key == "work" {
      let items = section("work")
      if items.len() > 0 {
        cv-section(labels.work)
        _render-work(items, labels, logos)
      }
    } else if key == "education" {
      cv-section(labels.education)
      _render-education(section("education"), labels, logos)
    } else if key == "projects" {
      cv-section(labels.projects)
      _render-projects(section("projects"), labels, logos)
    } else if key == "volunteer" {
      cv-section(labels.volunteer)
      _render-volunteer(section("volunteer"), labels, logos)
    } else if key == "certificates" {
      cv-section(labels.certificates)
      _render-honors(section("certificates"), section("awards"))
    } else if key == "skills" {
      cv-section(labels.skills)
      _render-skills(
        section("skills"),
        data.at("languages", default: ()),
        data.at("interests", default: ()),
        labels,
      )
    } else {
      panic("tailor: unknown section `" + key + "`")
    }
  }
}
