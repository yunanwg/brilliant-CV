// Regression: key-list's default was `list()` — a content element, not an
// array — so `cv-publication(ref-full: false)` without an explicit key-list
// crashed with "cannot loop over content". The default is now `()`; selecting
// nothing must compile (and render an empty publication list).

#import "/src/cv.typ": cv-publication

#cv-publication(
  bib: bibliography("pubs.bib"),
  ref-style: "ieee",
  ref-full: false,
)
