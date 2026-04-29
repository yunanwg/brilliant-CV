// expected: 'language' is removed in v4
//
// Asserts src/lib.typ:_check-v3-legacy panics when the v3 `language`
// shortcut field is present at top level. The panic fires before any
// schema-validation, so a minimal stub dict suffices.

#import "/src/lib.typ": cv

#show: cv.with((language: "en"))
