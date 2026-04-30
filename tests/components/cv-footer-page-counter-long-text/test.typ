// _cv-footer with display_page_counter = true and a long center caption.
//
// Pins the 3-column footer layout so a long center string isn't squeezed
// into a third of the page width (issue #173). The fix flipped the
// columns from `(1fr, 1fr, 1fr)` to `(auto, 1fr, auto)` so name and
// counter take their natural widths and the center text gets the rest.

#import "/src/cv.typ": _cv-footer
#import "/src/utils/styles.typ": _latin-font-list

#set page(width: 16cm, height: auto, margin: 0.5cm)
#set text(font: _latin-font-list, size: 9pt)

#let metadata = (
  cv_footer: "Senior Staff Software Engineer · Curriculum Vitae · Last Updated 2026",
  personal: (first_name: "Jane", last_name: "Doe"),
  layout: (
    footer: (display_page_counter: true, display_footer: true),
  ),
)

#context _cv-footer(metadata)
