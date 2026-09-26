/*
 * Functions for the cover letter template
 */

#import "./utils/styles.typ": _awesome-colors, _set-accent-color
#import "./utils/injection.typ": _inject
#import "./utils/identity.typ": _display-name

#let _letter-header(
  sender-address: "Your Address Here",
  recipient-name: "Company Name Here",
  recipient-address: "Company Address Here",
  date: "Today's Date",
  subject: "Subject: Hey!",
  metadata: metadata,
  awesome-colors: _awesome-colors,
  address-style: "smallcaps",
) = {
  let sender-name = _display-name(metadata)

  let accent-color = _set-accent-color(awesome-colors, metadata)

  // Keyword injection (consistent with CV)
  let inject = metadata.at("inject", default: (:))
  let custom-ai-prompt-text = inject.at("custom_ai_prompt_text", default: none)
  let keywords = inject.at("injected_keywords_list", default: ())
  _inject(
    custom-ai-prompt-text: custom-ai-prompt-text,
    keywords: keywords,
  )

  let letter-header-name-style(str) = {
    text(fill: accent-color, weight: "bold", str)
  }
  let letter-header-address-style(str) = {
    if address-style == "smallcaps" {
      text(fill: gray, size: 0.9em, smallcaps(str))
    } else {
      text(fill: gray, size: 0.9em, str)
    }
  }
  let letter-date-style(str) = {
    text(size: 0.9em, style: "italic", str)
  }
  let letter-subject-style(str) = {
    text(fill: accent-color, weight: "bold", underline(str))
  }

  letter-header-name-style(sender-name)
  v(1pt)
  letter-header-address-style(sender-address)
  v(1pt)
  align(right, letter-header-name-style(recipient-name))
  v(1pt)
  align(right, letter-header-address-style(recipient-address))
  v(1pt)
  letter-date-style(date)
  v(1pt)
  letter-subject-style(subject)
  linebreak()
  linebreak()
}

#let _letter-signature(img) = {
  set image(width: 25%)
  linebreak()
  // Keep the signature in the flow so it reserves its height: a placed
  // signature took no space and ran into the footer, or off the page, when
  // the body filled the page. An unbreakable block moves to the next page
  // instead.
  block(breakable: false, above: 0pt, width: 100%, align(right, move(
    dx: -5%,
    img,
  )))
}

#let _letter-footer(metadata) = {
  // Parameters
  let sender-name = _display-name(metadata)
  let letter-footer-text = metadata.at("letter_footer", default: "")
  let display-footer = metadata
    .layout
    .at("footer", default: {})
    .at("display_footer", default: true)

  if not display-footer {
    return none
  }

  // Styles
  let footer-style(str) = {
    text(size: 8pt, fill: rgb("#999999"), smallcaps(str))
  }

  table(
    columns: (1fr, auto),
    inset: 0pt,
    stroke: none,
    footer-style([#sender-name]), footer-style(letter-footer-text),
  )
}
