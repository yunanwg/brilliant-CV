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
