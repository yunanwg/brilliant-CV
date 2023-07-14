// awesomeCV-Typst 2023-07-05 mintyfrankie
// Github Repo: https://github.com/mintyfrankie/awesomeCV-Typst
// Typst version: 0.6.0

/* Packages */
#import "../metadata.typ": *
#import "@preview/fontawesome:0.1.0": *

/* Layout */

#let layout(doc) = {
  set text(
    font: ("Source Sans Pro", "Font Awesome 6 Brands", "Font Awesome 6 Free"),
    weight: "regular",
    size: 9pt,
  )
  set align(left)
  set page(
    paper: "a4",
    margin: (
      left: 1.4cm,
      right: 1.4cm,
      top: .8cm,
      bottom: .4cm,
    ),
  )
  doc
}

/* Utility Functions */

#let hBar() = [
  #h(5pt) | #h(5pt)
]

#let autoImport(file) = {
  if varLanguage == "" {
    include {"../modules/" + file + ".typ"}
  }
  else {
    include {"../modules_" + varLanguage + "/" + file + ".typ"}
  }
}

#let languageSwitch(dict) = {
  for (k, v) in dict {
    if k == varLanguage {
      return v
      break
    }
  }
  panic("i18n: language value not matching any key in the array")
}


/* Styles */

#let awesomeColors = (
  skyblue: rgb("#0395DE"),
  red: rgb("#DC3522"),
  nephritis: rgb("#27AE60"),
  concrete: rgb("#95A5A6"),
  darknight: rgb("#131A28"),
)

#let regularColors = (
  lightgray: rgb("#343a40"),
  darkgray: rgb("#212529"),
)

#let accentColor = awesomeColors.at(awesomeColor)

#let headerFont = "Roboto"

#let beforeSectionSkip = 1pt
#let beforeEntrySkip = 1pt
#let beforeEntryDescriptionSkip = 1pt

#let headerFirstNameStyle(str) = {text(
  font: headerFont,
  size: 32pt,
  weight: "light",
  fill: regularColors.darkgray,
  str
)}

#let headerLastNameStyle(str) = {text(
  font: headerFont,
  size: 32pt,
  weight: "bold",
  str
)}

#let headerInfoStyle(str) = {text(
  size: 10pt,
  fill: accentColor,
  str
)}

#let headerQuoteStyle(str) = {text(
  size: 10pt,
  weight: "medium",
  style: "italic",
  fill: accentColor,
  str
)}

#let sectionTitleStyle(str, color:black) = {text(
  size: 16pt, 
  weight: "bold", 
  fill: color,
  str
)}

#let entryA1Style(str) = {text(
  size: 10pt,
  weight: "bold",
  str
)}


#let entryA2Style(str) = {align(right, text(
  weight: "medium",
  fill: accentColor,
  style: "oblique",
  str
))}

#let entryB1Style(str) = {text(
  size: 8pt,
  fill: accentColor,
  weight: "medium",
  smallcaps(str)
)}

#let entryB2Style(str) = {align(right, text(
  size: 8pt,
  weight: "medium",
  fill: gray,
  style: "oblique",
  str
))}

#let entryDescriptionStyle(str) = {text(
  fill: regularColors.lightgray,
  {
    v(beforeEntryDescriptionSkip)
    str
  }
)}

#let skillTypeStyle(str) = {align(right, text(
  size: 10pt,
  weight: "bold",
  str))
}

#let skillInfoStyle(str) = {text(
  str
)}

#let honorDateStyle(str) = {align(right, text(
  str))
}

#let honorTitleStyle(str) = {text(
  weight: "bold",
  str
)}

#let honorIssuerStyle(str) = {text(
  str
)}

#let honorLocationStyle(str) = {align(right, text(
  weight: "medium",
  fill: accentColor,
  style: "oblique",
  str
))}

#let publicationStyle(str) = {text(
  str
)}

#let footerStyle(str) = {text(
  size: 8pt,
  fill: rgb("#999999"),
  smallcaps(str)
)}

#let letterHeaderNameStyle(str) = {text(
  fill: accentColor,
  weight: "bold",
  str
)}

#let letterHeaderAddressStyle(str) = {text(
  fill: gray,
  size: 0.9em,
  smallcaps(str)
)}

#let letterDateStyle(str) = {text(
  size: 0.9em,
  style: "italic",
  str
)}

#let letterSubjectStyle(str) = {text(
  fill: accentColor,
  weight: "bold",
  underline(str)
)}

/* Functions */

#let makeHeaderInfo() = {
  let personalInfoIcons = (
    phone: fa-phone(),
    email: fa-envelope(),
    linkedin: fa-linkedin(),
    homepage: fa-pager(),
    github: fa-square-github(),
    orcid: fa-orcid(),
    researchgate: fa-researchgate(),
    extraInfo: "",
  )
  let n = 1
  for (k, v) in personalInfo {
    if v != "" {
      // Adds hBar
      if n != 1 {
        hBar()
      }
      // Adds icons
      personalInfoIcons.at(k) + h(5pt)
      // Adds hyperlinks
      if k == "email" {
        link("mailto:" + v)[#v]
      } else if k == "linkedin" {
        link("https://www.linkedin.com/in/" + v)[#v]
      } else if k == "github" {
        link("https://github.com/" + v)[#v]
      } else if k == "homepage" {
        link("https://" + v)[#v]
      } else if k == "orcid" {
        link("https://orcid.org/" + v)[#v]
      } else if k == "researchgate" {
        link("https://www.researchgate.net/profile/" + v)[#v]
      } else {
        v
      }
    }
    n = n + 1
  }
}

#let makeHeaderNameSection() = table(
  columns: 1fr,
  inset: 0pt,
  stroke: none,
  row-gutter: 6mm,
  [#headerFirstNameStyle(firstName) #h(5pt) #headerLastNameStyle(lastName)],
  [#headerInfoStyle(makeHeaderInfo())],
  if headerQuote != "" [
    #headerQuoteStyle(headerQuote)
  ]
)

#let makeHeaderPhotoSection() = {
  if profilePhoto != "" {
    image(profilePhoto, height: 3.6cm)
  } else {
    v(3.6cm)
  }
} 

#let cvHeader(
  align: left,
  hasPhoto: true
) = {
  let makeHeader(leftComp, rightComp, columns, align) = table(
    columns: columns,
    inset: 0pt,
    stroke: none,
    column-gutter: 15pt,
    align: align + horizon,
    {leftComp},
    {rightComp}
  )
  if hasPhoto {
    makeHeader(makeHeaderNameSection(), makeHeaderPhotoSection(), (auto, 20%), align)
  } else {
    makeHeader(makeHeaderNameSection(), makeHeaderPhotoSection(), (auto, 0%), align)
  }
}

#let cvSection(title) = {
  let highlightText = title.slice(0,3)
  let normalText = title.slice(3)

  v(beforeSectionSkip)
  sectionTitleStyle(highlightText, color: accentColor)
  sectionTitleStyle(normalText, color: black)
  h(2pt)
  box(width: 1fr, line(stroke: 0.9pt, length: 100%))
}

#let cvEntry(
  title: "Title",
  society: "Society",
  date: "Date",
  location: "Location",
  description: "Description",
  logo: ""
) = {
  let ifLogo(path, ifTrue, ifFalse) = {
    return if varDisplayLogo {
      if path == "" { ifFalse } else { ifTrue }
    } else { ifFalse }
  }
  let setLogoLength(path) = {
    return if path == "" { 0% } else { 4% }
  }
  let setLogoContent(path) = {
    return if logo == "" [] else {image(path, width: 100%)}
  }
  v(beforeEntrySkip)
  table(
    columns: (ifLogo(logo, 4%, 0%), 1fr),
    inset: 0pt,
    stroke: none,
    align: horizon,
    column-gutter: ifLogo(logo, 4pt, 0pt),
    setLogoContent(logo),
    table(
      columns: (1fr, auto),
      inset: 0pt,
      stroke: none,
      row-gutter: 6pt,
      align: auto,
      {if varEntrySocietyFirst {entryA1Style(society)} else {entryA1Style(title)}},
      {entryA2Style(date)},
      {if varEntrySocietyFirst {entryB1Style(title)} else {entryB1Style(society)}},
      {entryB2Style(location)},
    )
  )
  entryDescriptionStyle(description)
}

#let cvSkill(
  type: "Type",
  info: "Info",
) = {
  table(
    columns: (16%, 1fr),
    inset: 0pt,
    column-gutter: 10pt,
    stroke: none,
    skillTypeStyle(type),
    skillInfoStyle(info),
  )
  v(-6pt)
}

#let cvHonor(
  date: "1990",
  title: "Title",
  issuer: "",
  location: ""
) = {
  table(
    columns: (16%, 1fr, 15%),
    inset: 0pt,
    column-gutter: 10pt,
    align: horizon,
    stroke: none,
    honorDateStyle(date),
    if issuer == "" {
      honorTitleStyle(title)
    } else [
      #honorTitleStyle(title), #honorIssuerStyle(issuer)
    ],
    honorLocationStyle(location)
  )
  v(-6pt)
}

#let cvPublication(
  bibPath: "",
  keyList: list(),
  refStyle: "apa",
) = {
  show cite: it => hide(it)
  show bibliography: it => publicationStyle(it)
  bibliography(bibPath, title: none, style: refStyle)
  for key in keyList {
    cite(key)
  }
  v(-15pt)
}


#let cvFooter() = {
  place(
    bottom,
    table(
      columns: (1fr, auto),
      inset: 0pt,
      stroke: none,
      footerStyle([#firstName #lastName]),
      footerStyle(languageSwitch(cvFooterInternational)),
    )
  )
}

#let letterHeader(
  myAddress: "Your Address Here",
  recipientName: "Company Name Here",
  recipientAddress: "Company Address Here",
  date: "Today's Date",
  subject: "Subject: Hey!"
) = {
  letterHeaderNameStyle(firstName + " " + lastName)
  v(1pt)
  letterHeaderAddressStyle(myAddress)
  v(1pt)
  align(right, letterHeaderNameStyle(recipientName))
  v(1pt)
  align(right, letterHeaderAddressStyle(recipientAddress))
  v(1pt)
  letterDateStyle(date)
  v(1pt)
  letterSubjectStyle(subject)
  linebreak(); linebreak()
}

#let letterSignature(path) = {
  linebreak()
  place(right, dx:-5%, dy:0%, image(path, width: 25%))
}

#let letterFooter() = {
  place(
    bottom,
    table(
      columns: (1fr, auto),
      inset: 0pt,
      stroke: none,
      footerStyle([#firstName #lastName]),
      footerStyle(languageSwitch(letterFooterInternational)),
    )
  )
}
