// Any personal-info entry with a link (custom or built-in: email, linkedin,
// github, gitlab, homepage, orcid, researchgate, phone) must make its icon
// clickable too, not just its trailing text. Icon-only badges (empty
// `text`) rely on this — otherwise the entry renders with no clickable area
// at all. Regression test for the icon-not-linked bug.

#import "/src/cv.typ": _make-header-info, _personal-info-icons

#let find-links(node) = {
  if type(node) != content { return () }
  let found = if node.func() == link { (node,) } else { () }
  let fields = node.fields()
  let children = if "body" in fields {
    (fields.body,)
  } else if "children" in fields {
    fields.children
  } else {
    ()
  }
  found + children.map(find-links).flatten()
}

// Case 1: custom entry, icon + label text — both should live inside the
// link body.
#let custom-with-text = _make-header-info(
  (
    custom-cert: (
      awesomeIcon: "certificate",
      text: "Certified",
      link: "https://example.com",
    ),
  ),
  _personal-info-icons,
  (:),
)
#custom-with-text
#context {
  let links = find-links(custom-with-text)
  assert.eq(links.len(), 1)
  // The link body is a sequence (icon + gap + text), not just the text
  // element on its own — i.e. the icon is part of the clickable body.
  assert.eq(repr(links.at(0).fields().body.func()), "sequence")
}

// Case 2: custom icon-only badge (empty text) must still produce a link
// wrapping the icon — not an empty, unclickable link — and must not leave
// a trailing gap where the (absent) text would have been.
#let custom-icon-only = _make-header-info(
  (
    custom-linkedin: (
      awesomeIcon: "linkedin",
      text: "",
      link: "https://www.linkedin.com/in/example/",
    ),
  ),
  _personal-info-icons,
  (:),
)
#custom-icon-only
#context {
  let links = find-links(custom-icon-only)
  assert.eq(links.len(), 1)
  // The link body is the icon itself, not a sequence padded with a
  // trailing h(5pt) gap for a text label that doesn't exist.
  assert.ne(repr(links.at(0).fields().body.func()), "sequence")
}

// Case 3: built-in field (email) — same requirement as custom entries.
#let builtin-email = _make-header-info(
  (email: "jane@example.com"),
  _personal-info-icons,
  (:),
)
#builtin-email
#context {
  let links = find-links(builtin-email)
  assert.eq(links.len(), 1)
  assert.eq(repr(links.at(0).fields().body.func()), "sequence")
}

// Case 4: built-in field with no link destination (location) must not
// produce a link element at all.
#let builtin-no-link = _make-header-info(
  (location: "Remote"),
  _personal-info-icons,
  (:),
)
#builtin-no-link
#context {
  let links = find-links(builtin-no-link)
  assert.eq(links.len(), 0)
}
