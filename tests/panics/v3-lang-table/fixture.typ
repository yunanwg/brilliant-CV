// expected: '[lang.<code>]' tables are removed in v4
//
// Asserts src/lib.typ:_check-v3-legacy panics when the v3 [lang.<code>]
// table structure is present. v4 hoists header_quote / cv_footer /
// letter_footer to top-level fields in profile_<name>/metadata.toml.

#import "/src/lib.typ": cv

#show: cv.with((
  lang: (en: (header_quote: "x", cv_footer: "y", letter_footer: "z")),
))
