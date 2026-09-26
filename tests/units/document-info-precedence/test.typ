// A `set document(...)` the user writes before the show rule wins over the
// package's metadata, field by field; fields the user leaves at the default
// are filled by cv().

#import "/src/lib.typ": cv
#import "/tests/common.typ": minimal-metadata

#set document(title: "My own title", keywords: ("mine",))
#show: cv.with(minimal-metadata)

#context {
  assert.eq(document.title, [My own title])
  assert.eq(document.keywords, ("mine",))
  assert.eq(document.author, ("Jane Doe",))
}
