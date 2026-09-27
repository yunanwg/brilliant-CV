/*
 * Style parts: named visual pieces of the CV that users can restyle.
 *
 * Each part renders its text inside an outer `set text(...)` rule built
 * from the package defaults and the user's `[layout.parts.<name>]` values,
 * and labels the innermost text `<bcv-<name>>`. Two ways to customize
 * therefore reach the same place:
 *
 * - `[layout.parts.entry-primary] size = "11pt"` in metadata.toml (stable);
 * - `#show <bcv-entry-primary>: set text(size: 11pt)` (experimental).
 *
 * Package defaults sit in a set rule, not in `text()` arguments, because
 * arguments outrank set and show rules and would lock the user out.
 */

/// Parts that `[layout.parts]` accepts. Positional names follow the layout,
/// not the meaning: `entry-primary` is the bold first line of an entry,
/// which is the society or the title depending on
/// `display_entry_society_first`.
#let _part-names = (
  // CV header
  "name-first",
  "name-last",
  "header-info",
  "header-quote",
  // Sections and entries
  "section-title",
  "entry-primary",
  "entry-primary-aside",
  "entry-secondary",
  "entry-secondary-aside",
  "entry-description",
  "entry-tag",
  // Skills, honors, publications
  "skill-type",
  "skill-info",
  "skill-tag",
  "honor-date",
  "honor-title",
  "honor-issuer",
  "honor-location",
  "publication",
  // Cover letter
  "letter-sender-name",
  "letter-sender-address",
  "letter-recipient-name",
  "letter-recipient-address",
  "letter-date",
  "letter-subject",
  // CV and cover letter
  "footer",
)

/// Text properties a part accepts.
#let _part-properties = ("size", "weight", "style", "fill", "font")

#let _parse-part-value(part, key, value, awesome-colors) = {
  let where = "[layout.parts." + part + "] " + key
  if key == "size" {
    // Same pattern as the schema's `length`; checked before eval so a bad
    // value reports itself instead of an eval error.
    let pattern = regex("^(?:0|[1-9][0-9]*)(?:\\.[0-9]+)?(?:pt|mm|cm|in|em)$")
    if type(value) != str or value.match(pattern) == none {
      panic(where + " must be a length such as \"11pt\", got " + repr(value))
    }
    eval(value)
  } else if key == "fill" {
    // Same value space as the schema and [layout] awesome_color.
    let hex = regex("^#([0-9a-fA-F]{3}|[0-9a-fA-F]{6})$")
    if (
      type(value) != str
        or (value not in awesome-colors and value.match(hex) == none)
    ) {
      panic(
        where
          + " must be a color name ("
          + awesome-colors.keys().join(", ")
          + ") or \"#rrggbb\", got "
          + repr(value),
      )
    }
    if value in awesome-colors { awesome-colors.at(value) } else { rgb(value) }
  } else if key == "style" {
    if value not in ("normal", "italic", "oblique") {
      panic(
        where
          + " must be \"normal\", \"italic\", or \"oblique\", got "
          + repr(value),
      )
    }
    value
  } else {
    // weight (name or 100-900) and font (name or fallback list) pass through;
    // `set text` reports an invalid value itself.
    value
  }
}

/// Read and validate `[layout.parts]` from metadata.
///
/// An unknown part or property panics instead of being ignored, so a typo
/// cannot silently leave the CV unchanged.
///
/// - metadata (dictionary): the metadata object
/// - awesome-colors (dictionary): named colors accepted for `fill`
/// -> dictionary
#let _resolve-parts(metadata, awesome-colors) = {
  let configured = metadata.layout.at("parts", default: (:))
  let resolved = (:)
  for (part, properties) in configured {
    if part not in _part-names {
      panic(
        "unknown style part [layout.parts."
          + part
          + "]; known parts: "
          + _part-names.join(", "),
      )
    }
    let parsed = (:)
    for (key, value) in properties {
      if key not in _part-properties {
        panic(
          "unknown property [layout.parts."
            + part
            + "] "
            + key
            + "; known properties: "
            + _part-properties.join(", "),
        )
      }
      parsed.insert(key, _parse-part-value(part, key, value, awesome-colors))
    }
    resolved.insert(part, parsed)
  }
  resolved
}

/// Render `body` as the style part `name`.
///
/// `parts` is the result of `_resolve-parts`, or a function returning it.
/// Components that take no `metadata` argument pass a function, which runs
/// in context around the text only, so they need no context wrapper of
/// their own and still render with the defaults outside `cv()`.
///
/// - name (str): the part name, e.g. `"entry-primary"`
/// - defaults (dictionary): the package's `text` properties for this part
/// - parts (dictionary | function): resolved parts, or `() => dictionary`
/// - body (str | content): the text to render
/// -> content
#let _part(name, defaults, parts, body) = {
  let render(resolved) = {
    set text(..defaults, ..resolved.at(name, default: (:)))
    [#text(body)#label("bcv-" + name)]
  }
  if type(parts) == function { context render(parts()) } else { render(parts) }
}
