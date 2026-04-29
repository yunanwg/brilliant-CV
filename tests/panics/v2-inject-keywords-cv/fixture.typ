// expected: 'inject_keywords' has been removed since v3
//
// Asserts src/cv.typ:223 panics inside _cv-header when the v2
// inject_keywords boolean is present. v3+ uses injected_keywords_list
// directly — its presence implies injection.

#import "/src/lib.typ": cv
#import "/tests/common.typ": minimal-metadata

#let bad = (
  ..minimal-metadata,
  inject: (inject_keywords: true),
)

#show: cv.with(bad)
