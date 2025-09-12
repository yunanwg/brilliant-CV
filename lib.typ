/*
* Entry point for the package
*/

/* Packages */
#import "./cv.typ": *
#import "./letter.typ": *
#import "./utils/lang.typ": *
#import "./utils/styles.typ": *

/* Layout */
#let cv(
  metadata,
  profilePhoto: image("./template/src/avatar.png"),
  doc,
) = {
  // Non Latin Logic
  let lang = metadata.language
  let fonts = _latin-font-list
  let header-font = _latin-header-font

  fonts = overwrite-fonts(metadata, _latin-font-list, _latin-header-font).regular-fonts
  header-font = overwrite-fonts(metadata, _latin-font-list, _latin-header-font).header-font
  
  if _is-non-latin(lang) {
    let nonLatinFont = metadata.lang.non_latin.font
    fonts.insert(2, nonLatinFont)
    header-font = nonLatinFont
  }

  // Page layout
  set text(font: fonts, weight: "regular", size: 9pt)
  set align(left)
  let paper_size = metadata.layout.at("paper_size", default: "a4")
  set page(
    paper: {paper_size},
    margin: {
      if paper_size == "us-letter" {
        (left: 2cm, right: 1.4cm, top: 1.2cm, bottom: 1.2cm)
        } else {
        (left: 1.4cm, right: 1.4cm, top: 1cm, bottom: 1cm)
      }
    },
    footer: context _cv-footer(metadata),
  )

  _cv-header(metadata, profilePhoto, header-font, _regular-colors, _awesome-colors)
  doc
}

#let letter(
  metadata,
  doc,
  myAddress: "Your Address Here",
  recipientName: "Company Name Here",
  recipientAddress: "Company Address Here",
  date: datetime.today().display(),
  subject: "Subject: Hey!",
  signature: "",
) = {
  // Non Latin Logic
  let lang = metadata.language
  let fonts = _latin-font-list
  fonts = overwrite-fonts(metadata, _latin-font-list, _latin-header-font).regular-fonts
  if _is-non-latin(lang) {
    let non-latin-font = metadata.lang.non_latin.font
    fonts.insert(2, non-latin-font)
  }

  // Page layout
  set text(font: fonts, weight: "regular", size: 9pt)
  set align(left)
  let paper-size = metadata.layout.at("paper_size", default: "a4")
  set page(
    paper: {paper-size},
    margin: {
      if paper-size == "us-letter" {
        (left: 2cm, right: 2cm, top: 1.2cm, bottom: 1.2cm)
        } else {
        (left: 1.4cm, right: 1.4cm, top: 1cm, bottom: 1cm)
      }
    },
    footer: _letter-footer(metadata),
  )
  set text(size: 12pt)

  _letter-header(
      sender-address: myAddress,
      recipient-name: recipientName,
      recipient-address: recipientAddress,
      date: date,
      subject: subject,
      metadata: metadata,
      awesome-colors: _awesome-colors,
    )
  doc

  if signature != "" {
    _letter-signature(signature)
  }
}
