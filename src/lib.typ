/*
* Entry point for the package
*/

/* Packages */
#import "./cv.typ": *
#import "./letter.typ": *
#import "./utils/lang.typ": *
#import "./utils/styles.typ": *
#import "./utils/merge.typ": deep-merge

/* Layout */

/// Render a CV document with header, footer, and page layout applied.
///
/// - metadata (dictionary): The metadata dictionary read from `metadata.toml`.
/// - doc (content): The body content of the CV (typically the imported modules).
/// - profile-photo (image | none): The profile photo to display in the header. Defaults to `none`; pass an `image(...)` to render. When `none`, the photo column is hidden regardless of `display_profile_photo`.
/// - custom-icons (dictionary): Custom icons to override or extend the default icon set.
/// -> content
#let cv(
  metadata,
  doc,
  profile-photo: none,
  custom-icons: (:),
) = {
  // Update metadata state
  cv-metadata.update(metadata)

  // Non Latin Logic
  let lang = metadata.language
  let fonts = _latin-font-list
  let header-font = _latin-header-font

  let font-config = overwrite-fonts(metadata, _latin-font-list, _latin-header-font)
  fonts = font-config.regular-fonts
  header-font = font-config.header-font
  
  if _is-non-latin(lang) {
    let non-latin-font = metadata.at("non_latin_font", default: none)
    // Backward compat: fall back to legacy [lang.non_latin] section (remove when deprecating)
    if non-latin-font == none {
      non-latin-font = metadata.at("lang", default: (:)).at("non_latin", default: (:)).at("font", default: none)
    }
    if non-latin-font != none {
      fonts.push(non-latin-font)
      header-font = non-latin-font
    }
  }

  let font_size = eval(
    metadata.layout.at("font_size", default: "9pt")
  )
  // Page layout
  set text(font: fonts, weight: "regular", size: font_size, fill: _regular-colors.lightgray)
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

  _cv-header(metadata, profile-photo, header-font, _regular-colors, _awesome-colors, custom-icons)
  doc
}

/// Render a cover letter document with header, footer, and page layout applied.
///
/// - metadata (dictionary): The metadata dictionary read from `metadata.toml`.
/// - doc (content): The body content of the letter.
/// - sender-address (str | auto): The sender's mailing address. Defaults to `auto`, which reads from `metadata.personal.address` (falls back to `"Your Address Here"` if unset). Pass a string or content to override.
/// - recipient-name (str): The recipient's name or company displayed in the header.
/// - recipient-address (str): The recipient's mailing address displayed in the header. Supports multiline content.
/// - date (str): The date displayed in the letter header. Defaults to today's date.
/// - subject (str): The subject line of the letter.
/// - signature (str | content): (optional) path to a signature image, or content to display as signature.
/// - address-style (str): Address rendering style. `"smallcaps"` (default) or `"normal"`.
/// -> content
#let letter(
  metadata,
  doc,
  sender-address: auto,
  recipient-name: "Company Name Here",
  recipient-address: "Company Address Here",
  date: datetime.today().display(),
  subject: "Subject: Hey!",
  signature: "",
  address-style: "smallcaps",
) = {
  // Resolve sender-address: auto reads from metadata, explicit value overrides
  let sender-address = if sender-address == auto {
    metadata.personal.at("address", default: "Your Address Here")
  } else {
    sender-address
  }

  // Schema migration guard: panic on v2 inject keys so users get a clear
  // upgrade message rather than silent no-op.
  let inject = metadata.at("inject", default: (:))
  if inject.at("inject_ai_prompt", default: none) != none {
    panic("'inject_ai_prompt' has been removed since v3. Use 'custom_ai_prompt_text' in [inject] instead.")
  }
  if inject.at("inject_keywords", default: none) != none {
    panic("'inject_keywords' has been removed since v3. Use 'injected_keywords_list' directly — if the list is present, keywords are injected. To disable injection, remove 'injected_keywords_list'.")
  }

  // Non Latin Logic
  let lang = metadata.language
  let fonts = _latin-font-list
  let header-font = _latin-header-font
  let font-config = overwrite-fonts(metadata, _latin-font-list, _latin-header-font)
  fonts = font-config.regular-fonts
  header-font = font-config.header-font
  if _is-non-latin(lang) {
    let non-latin-font = metadata.at("non_latin_font", default: none)
    // Backward compat: fall back to legacy [lang.non_latin] section (remove when deprecating)
    if non-latin-font == none {
      non-latin-font = metadata.at("lang", default: (:)).at("non_latin", default: (:)).at("font", default: none)
    }
    if non-latin-font != none {
      fonts.push(non-latin-font)
    }
  }

  // Font size from metadata (consistent with CV)
  let font-size = eval(
    metadata.layout.at("font_size", default: "9pt")
  )

  // Page layout
  set text(font: fonts, weight: "regular", size: font-size, fill: _regular-colors.lightgray)
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
      sender-address: sender-address,
      recipient-name: recipient-name,
      recipient-address: recipient-address,
      date: date,
      subject: subject,
      metadata: metadata,
      awesome-colors: _awesome-colors,
      address-style: address-style,
    )
  doc

  if signature != "" {
    _letter-signature(signature)
  }
}
