// expected: 'non_latin_name' is removed in v4
//
// Asserts src/lib.typ:_check-v3-legacy panics when the v3 `non_latin_name`
// field is present. v4 replaces this with [personal] display_name.

#import "/src/lib.typ": cv

#show: cv.with((non_latin_name: "王道尔"))
