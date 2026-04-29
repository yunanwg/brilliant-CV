// expected: 'non_latin_font' is removed in v4
//
// Asserts src/lib.typ:_check-v3-legacy panics when the v3 `non_latin_font`
// field is present. v4 replaces this with [layout.fonts] regular_fonts +
// header_font.

#import "/src/lib.typ": cv

#show: cv.with((non_latin_font: "Heiti SC"))
