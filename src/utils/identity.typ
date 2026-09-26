/*
 * Candidate identity shared by the CV and the cover letter.
 */

/// Resolve the candidate's name as plain text for places that show it
/// without the header's first/last styling (footers, letter header).
///
/// `[personal] display_name` wins when set, so a CJK profile shows the same
/// name everywhere; otherwise the name is `first_name + " " + last_name`.
///
/// - metadata (dictionary): the metadata object
/// -> str
#let _display-name(metadata) = {
  let display-name = metadata.personal.at("display_name", default: none)
  if display-name != none {
    display-name
  } else {
    metadata.personal.first_name + " " + metadata.personal.last_name
  }
}
