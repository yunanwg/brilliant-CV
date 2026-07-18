// Regression for issue #181: when both the top-row fields (title + date) are
// empty, the entry must NOT reserve their blank line — the society + location
// should collapse up to the first line. The bottom entry keeps a one-sided gap
// (date only) to prove the surviving text stays aligned with its counterpart.

#import "/src/cv.typ": cv-entry, cv-metadata
#import "/src/utils/styles.typ": _regular-colors
#import "/tests/common.typ": minimal-metadata, test-font-list

#set page(width: 16cm, height: auto, margin: 0.5cm)
#set text(font: test-font-list, size: 9pt, fill: _regular-colors.lightgray)

// title-first layout (display_entry_society_first = false) — the configuration
// the reporter uses, where title + date sit on the dropped top row.
#let md = minimal-metadata
#let md = {
  let m = md
  m.layout.entry.display_entry_society_first = false
  m
}
#cv-metadata.update(_ => md)

// Both title and date removed: top row should collapse entirely.
#cv-entry(
  title: "",
  society: [github.com/acme/widget],
  date: "",
  location: [Open Source],
  description: list([A small utility library.]),
)

// Only the date removed: the title still occupies the top row, and location
// must stay aligned with the society on the bottom row (no upward jump).
#cv-entry(
  title: [Maintainer],
  society: [github.com/acme/gadget],
  date: "",
  location: [Open Source],
  description: list([Another utility library.]),
)
