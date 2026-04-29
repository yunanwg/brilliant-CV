// _get-layout-value eval's the metadata-supplied value when the key is
// present. Used throughout cv.typ for spacing values like before_entry_skip.

#import "/src/cv.typ": _get-layout-value

#let metadata = (layout: (before_entry_skip: "1.5em"))

#assert.eq(_get-layout-value(metadata, "before_entry_skip", "0pt"), 1.5em)
