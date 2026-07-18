// Regression: before_entry_skip / before_entry_description_skip defaults were
// length literals (1pt) passed to the string-only eval(), so OMITTING either
// key crashed instead of falling back to 1pt. All shipped profiles set both
// keys, which is why the broken fallback went unnoticed. This fixture drops
// both keys and must still compile.

#import "/src/cv.typ": cv-entry, cv-metadata
#import "/tests/common.typ": minimal-metadata

#let md = {
  let m = minimal-metadata
  let _ = m.layout.remove("before_entry_skip")
  let _ = m.layout.remove("before_entry_description_skip")
  m
}
#cv-metadata.update(_ => md)

#cv-entry(
  title: [Maintainer],
  society: [github.com/acme/widget],
  date: [2020 - 2024],
  location: [Open Source],
  description: list([A small utility library.]),
)
