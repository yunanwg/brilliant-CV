// cv-publication with ref-full: true — every entry in the bib file is
// rendered regardless of key-list (key-list is only consulted when
// ref-full is false). Reuses the fixture bib from cv-publication-keylist/
// via a root-relative path rather than duplicating it.
//
// cv-publication doesn't read cv-metadata (unlike cv-entry/cv-honor/etc.),
// so no minimal-metadata or cv() wrapper is needed — call it directly.

#import "/src/lib.typ": cv-publication

#cv-publication(
  bib: bibliography("/tests/units/cv-publication-keylist/pubs.bib"),
  ref-style: "apa",
  ref-full: true,
)
