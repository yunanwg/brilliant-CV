// _document-info builds the PDF metadata that cv() and letter() set:
// title "<name> — <label>", author = resolved name, keywords from
// [inject] injected_keywords_list.

#import "/src/utils/identity.typ": _document-info
#import "/tests/common.typ": minimal-metadata

#let info = _document-info(minimal-metadata, "Curriculum vitae")
#assert.eq(info.title, "Jane Doe — Curriculum vitae")
#assert.eq(info.author, "Jane Doe")
#assert.eq(info.keywords, ())

// An empty or missing label leaves the name alone.
#assert.eq(_document-info(minimal-metadata, "").title, "Jane Doe")
#assert.eq(_document-info(minimal-metadata, none).title, "Jane Doe")

// display_name wins for both title and author.
#let zh = (
  ..minimal-metadata,
  personal: (..minimal-metadata.personal, display_name: "王道尔"),
  inject: (injected_keywords_list: ("SQL", "Python")),
)
#let zh-info = _document-info(zh, "简历")
#assert.eq(zh-info.title, "王道尔 — 简历")
#assert.eq(zh-info.author, "王道尔")
#assert.eq(zh-info.keywords, ("SQL", "Python"))

// A content label (e.g. a letter subject) gives a content title.
#assert.eq(type(_document-info(minimal-metadata, [Subject]).title), content)

// PDF authors must be strings: a content-valued name leaves the author empty.
#let content-name = (
  ..minimal-metadata,
  personal: (..minimal-metadata.personal, first_name: [Jane]),
)
#assert.eq(_document-info(content-name, none).author, ())
