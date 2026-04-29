// expected: 'inject_keywords' has been removed since v3
//
// Asserts src/lib.typ:164 panics inside letter() when the v2
// inject_keywords boolean is present.

#import "/src/lib.typ": letter
#import "/tests/common.typ": minimal-metadata

#let bad = (
  ..minimal-metadata,
  inject: (inject_keywords: true),
)

#show: letter.with(bad, date: "2026-01-01")
