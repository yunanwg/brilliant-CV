// cv-publication with ref-full: false and an explicit key-list — only the
// bib keys named in key-list get cited, so the bibliography renders a
// selective subset instead of every entry in the .bib file. (A separate,
// already-tracked bug covers calling ref-full: false with no key-list —
// this test always pairs the two.)
//
// cv-publication doesn't read cv-metadata (unlike cv-entry/cv-honor/etc.),
// so no minimal-metadata or cv() wrapper is needed — call it directly.

#import "/src/lib.typ": cv-publication

#cv-publication(
  bib: bibliography("/tests/units/cv-publication-keylist/pubs.bib"),
  key-list: ("doe2024",),
  ref-style: "ieee",
  ref-full: false,
)
