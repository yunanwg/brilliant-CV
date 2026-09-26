/*
 * Candidate identity shared by the CV and the cover letter.
 */

/// Read `[personal] display_name`, or `none` when the profile does not set
/// it. The CV header uses this to choose between the display name and its
/// styled first/last split; every other name slot goes through
/// `_display-name`.
///
/// - metadata (dictionary): the metadata object
/// -> str | content | none
#let _display-name-override(metadata) = {
  metadata.personal.at("display_name", default: none)
}

/// Resolve the candidate's name for places that show it without the
/// header's first/last styling (footers, letter header).
///
/// `[personal] display_name` wins when set, so a CJK profile shows the same
/// name everywhere; otherwise the name is `first_name + " " + last_name`.
/// Names are strings when read from TOML, and may be content when the
/// metadata is built in Typst.
///
/// - metadata (dictionary): the metadata object
/// -> str | content
#let _display-name(metadata) = {
  let display-name = _display-name-override(metadata)
  if display-name != none {
    display-name
  } else {
    metadata.personal.first_name + " " + metadata.personal.last_name
  }
}

/// Build the PDF document metadata (title, author, keywords) for a CV or a
/// cover letter. Pass the result to `set document(..info)`.
///
/// - The title is `<name> — <label>`, or the name alone when `label` is
///   `none` or empty. The CV passes its `cv_footer`; the letter passes its
///   subject.
/// - The author is the resolved name when it is a string. PDF authors must be
///   strings, so a content-valued name built in Typst leaves it empty.
/// - The keywords are `[inject] injected_keywords_list`: declared openly in
///   the standard PDF field that ATS parsers and search tools read.
///
/// - metadata (dictionary): the metadata object
/// - label (str | content | none): the document label after the name
/// -> dictionary
#let _document-info(metadata, label) = {
  let name = _display-name(metadata)
  let title = if label == none or label == "" {
    name
  } else if type(name) == str and type(label) == str {
    name + " — " + label
  } else {
    [#name — #label]
  }
  let keywords = metadata
    .at("inject", default: (:))
    .at("injected_keywords_list", default: ())
  (
    title: title,
    author: if type(name) == str { name } else { () },
    keywords: keywords,
  )
}
