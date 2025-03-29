/*
 * Functions for the CV template
 */

#import "./utils/styles.typ": *

#let _letterHeader(
  myAddress: "Your Address Here",
  recipientName: "Company Name Here",
  recipientAddress: "Company Address Here",
  date: "Today's Date",
  subject: "Subject: Hey!",
  metadata: metadata,
  awesomeColors: awesomeColors,
) = {
  let accentColor = setAccentColor(awesomeColors, metadata)

  let letterHeaderNameStyle(str) = {
    text(fill: accentColor, weight: "bold", str, size: 10pt)
  }
  let letterHeaderAddressStyle(str) = {
    text(fill: gray, size: 10pt, smallcaps(str))
  }
  let letterDateStyle(str) = {
    text(size: 10pt, style: "italic", str)
  }
  let letterSubjectStyle(str) = {
    text(fill: accentColor, weight: "bold", underline(str), size: 10pt)
  }

  letterHeaderNameStyle(metadata.personal.first_name + " " + metadata.personal.last_name)
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
  v(1pt)
}

#let _letterSignature(img) = {
  set image(height: 1.5cm)
  linebreak()
  place(left, dx: -0.5%, dy: -2.25%, img)
}

#let _letterFooter(metadata) = {
  // Parameters
  let firstName = metadata.personal.first_name
  let lastName = metadata.personal.last_name
  let footerText = metadata.lang.at(metadata.language).letter_footer

  // Styles
  let footerStyle(str) = {
    text(size: 8pt, fill: rgb("#999999"), smallcaps(str))
  }

  return table(
    columns: (1fr, auto),
    inset: 0pt,
    stroke: none,
    footerStyle([#firstName #lastName]), footerStyle(metadata.lang.at(metadata.language).letter_footer),
  )
}
