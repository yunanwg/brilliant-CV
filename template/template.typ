// brilliant-CV 2023-11-01 mintyfrankie
// Github Repo: https://github.com/mintyfrankie/brilliant-CV
// Typst version: 0.9.0

/* Packages */
#import "../metadata.typ": *
#import "@preview/fontawesome:0.1.0": *


/* Language-specific Macros */
#let nonLatinOverwrite = false
#let nonLatinFont = ""
#let nonLatinLanguageCode = ("zh", "ja", "ko", "ru")
#for lang in nonLatinLanguageCode {
  if varLanguage == lang {
    nonLatinOverwrite = true
    firstName = nonLatinOverwriteInfo.at("firstName")
    lastName = nonLatinOverwriteInfo.at("lastName")
    nonLatinFont = nonLatinOverwriteInfo.at("customFont")
  }
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
#let fontList = ("Source Sans Pro", nonLatinFont, "Font Awesome 6 Brands", "Font Awesome 6 Free")

#let headerFont = ("Roboto", nonLatinFont)

#let awesomeColors = (
  skyblue: rgb("#0395DE"),
  red: rgb("#DC3522"),
  nephritis: rgb("#27AE60"),
  concrete: rgb("#95A5A6"),
  darknight: rgb("#131A28"),
)

#let regularColors = (
  subtlegray: rgb("#ededee"),
  lightgray: rgb("#343a40"),
  darkgray: rgb("#212529"),
)

#let accentColor = {
  if type(awesomeColor) == color {
    awesomeColor
  } else {
    awesomeColors.at(awesomeColor)
  }
}

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

#let entryTagStyle(str) = {align(center, text(
  size: 8pt,
  weight: "regular",
  str
))}

#let entryTagListStyle(tags) = {for tag in tags {
  box(
    inset: (x: 0.25em),
    outset: (y: 0.25em),
    fill: regularColors.subtlegray, 
    radius: 3pt,
    entryTagStyle(tag),
  )
  h(5pt)
}}


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
#let cvHeader(
  align: left,
  hasPhoto: true
) = {
  let makeHeaderInfo() = {
    let personalInfoIcons = (
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
    for (k, v) in personalInfo {
      // A dirty trick to add linebreaks with "linebreak" as key in personalInfo
      if k == "linebreak" {
        n = 0
        linebreak()
        continue
      }
      if k.contains("custom") {
        // example value (icon: fa-graduation-cap(), text: "PhD", link: "https://www.example.com")
        let icon = v.at("icon", default: "")
        let text = v.at("text", default: "")
        let link_value = v.at("link", default: "")
        box({
          icon
          h(5pt)
          link(link_value)[#text]
        })
        continue
      }
      if v != "" {box({
        
        // Adds icons
        personalInfoIcons.at(k) + h(5pt)
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
        } else {
          v
        }
      })} 
      // Adds hBar
        if n != personalInfo.len() {
          hBar() 
        }
      n = n + 1
    }
  }

  let makeHeaderNameSection() = table(
    columns: 1fr,
    inset: 0pt,
    stroke: none,
    row-gutter: 6mm,
    [#headerFirstNameStyle(firstName) #h(5pt) #headerLastNameStyle(lastName)],
    [#headerInfoStyle(makeHeaderInfo())],
    [#headerQuoteStyle(languageSwitch(headerQuoteInternational))]
  )


  let makeHeaderPhotoSection() = {
    if profilePhoto != "" {
      image(profilePhoto, height: 3.6cm)
    } else {
      v(3.6cm)
    }
  } 

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

#let cvSection(title, highlighted: true, letters: 3) = {
  let highlightText = title.slice(0,letters)
  let normalText = title.slice(letters)

  v(beforeSectionSkip)
  if nonLatinOverwrite {
    sectionTitleStyle(title, color: accentColor)
  } else {
    if highlighted {
    sectionTitleStyle(highlightText, color: accentColor)
    sectionTitleStyle(normalText, color: black)
    } else {
      sectionTitleStyle(title, color: black)
    }
  }
  h(2pt)
  box(width: 1fr, line(stroke: 0.9pt, length: 100%))
}

#let cvEntry(
  title: "Title",
  society: "Society",
  date: "Date",
  location: "Location",
  description: "Description",
  logo: "",
  tags: ()
) = {
  let ifSocietyFirst(condition, field1, field2) = {
    return if condition {field1} else {field2}
  }
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
      {entryA1Style(ifSocietyFirst(varEntrySocietyFirst, society, title))},
      {entryA2Style(ifSocietyFirst(varEntrySocietyFirst, location,date))},
      {entryB1Style(ifSocietyFirst(varEntrySocietyFirst, title, society))},
      {entryB2Style(ifSocietyFirst(varEntrySocietyFirst, date,location))},
    )
  )
  entryDescriptionStyle(description)
  entryTagListStyle(tags)
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
  url: "",
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
    } else if url != "" { [
      #honorTitleStyle(link(url)[#title]), #honorIssuerStyle(issuer)
    ] } else { [
      #honorTitleStyle(title), #honorIssuerStyle(issuer)
    ]},
    honorLocationStyle(location)
  )
  v(-6pt)
}

#let cvPublication(
  bibPath: "",
  keyList: list(),
  refStyle: "apa",
  refFull: true,
) = {
  show bibliography: it => publicationStyle(it)
  bibliography(bibPath, title: none, style: refStyle, full: refFull)
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


/* Layout */
#let layout(doc) = {
  set text(
    font: fontList,
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
