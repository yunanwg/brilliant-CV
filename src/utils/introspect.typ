/*
 * Experimental: machine-readable layout hooks for agents and scripts.
 *
 * With `--input brilliant-cv-query=1`, every component also emits an
 * invisible `metadata` element labelled `<brilliant-cv>`. `typst query`
 * then returns what was rendered and on which page, without rendering
 * images. Field names may change in a minor release.
 */

/// True when the caller asked for layout hooks with
/// `--input brilliant-cv-query=1` (or `=true`).
/// -> bool
#let _query-enabled() = {
  sys.inputs.at("brilliant-cv-query", default: "") in ("1", "true")
}

/// Flatten content to plain text, so that query results are strings and not
/// serialized content trees. Line breaks, spacing, and list items become
/// single spaces; images and other non-text elements are dropped.
///
/// - it (any): the value to flatten
/// -> str
#let _plain-text(it) = {
  // `array.join` returns none for an empty array; text must stay a string.
  let join(parts, separator) = if parts.len() == 0 { "" } else {
    parts.join(separator)
  }
  let flatten(it) = {
    if it == none {
      ""
    } else if type(it) == str {
      it
    } else if type(it) in (int, float) {
      str(it)
    } else if type(it) == array {
      join(it.map(flatten), " ")
    } else if type(it) != content {
      ""
    } else if it.has("text") {
      it.text
    } else if it.func() in (list, enum) {
      join(it.children.map(flatten), " ")
    } else if it.has("children") {
      join(it.children.map(flatten), "")
    } else if it.has("body") {
      flatten(it.body)
    } else if it.has("child") {
      flatten(it.child)
    } else if it.func() in (linebreak, parbreak) or it == [ ] {
      " "
    } else {
      ""
    }
  }
  flatten(it).replace(regex("\s+"), " ").trim()
}

/// Emit one hook element when hooks are enabled; otherwise nothing.
/// `page` is the physical page on which the element ends.
///
/// - kind (str): the element kind, e.g. `"entry"`
/// - fields (dictionary): values to flatten with `_plain-text`
/// -> content
#let _emit(kind, ..fields) = {
  if _query-enabled() {
    let values = fields
      .named()
      .pairs()
      .map(((key, value)) => (
        key,
        if type(value) == array and value.all(v => type(v) == str) {
          value
        } else if type(value) == int {
          value
        } else {
          _plain-text(value)
        },
      ))
    context {
      let extra = if kind == "document" { (pages: here().page()) } else {
        (:)
      }
      [#metadata((
        kind: kind,
        page: here().page(),
        ..extra,
        ..values.to-dict(),
      )) <brilliant-cv>]
    }
  }
}
