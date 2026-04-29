// expected: 'inject_ai_prompt' has been removed since v3
//
// Asserts src/cv.typ:218 panics inside _cv-header when the v2
// inject_ai_prompt key is present. v3+ replaces this with
// custom_ai_prompt_text in [inject].

#import "/src/lib.typ": cv
#import "/tests/common.typ": minimal-metadata

#let bad = (
  ..minimal-metadata,
  inject: (inject_ai_prompt: true),
)

#show: cv.with(bad)
