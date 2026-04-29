// expected: 'inject_ai_prompt' has been removed since v3
//
// Asserts src/lib.typ:159 panics inside letter() when the v2
// inject_ai_prompt key is present. Mirrors the cv() guard so users
// hit the same error from either entry point.

#import "/src/lib.typ": letter
#import "/tests/common.typ": minimal-metadata

#let bad = (
  ..minimal-metadata,
  inject: (inject_ai_prompt: true),
)

#show: letter.with(bad, date: "2026-01-01")
