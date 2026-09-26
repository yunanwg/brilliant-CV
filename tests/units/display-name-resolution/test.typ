// The CV footer and every letter name slot resolve the candidate's name
// through _display-name: [personal] display_name wins when set, so a CJK
// profile no longer shows its Latin first/last name in footers and the
// letter header.

#import "/src/utils/identity.typ": _display-name
#import "/tests/common.typ": minimal-metadata

#assert.eq(_display-name(minimal-metadata), "Jane Doe")

#let with-display-name = (
  ..minimal-metadata,
  personal: (..minimal-metadata.personal, display_name: "王道尔"),
)
#assert.eq(_display-name(with-display-name), "王道尔")
