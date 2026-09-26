// Validates the JSON that `typst query ... '<brilliant-cv>' --field value`
// returns for one fixture. tests/query/run.sh compiles this file with
// --input result=<root-relative path> --input pages=<PDF page count>; any
// failed assertion makes the compile, and so the test, fail.

#let items = json(sys.inputs.result)
#let pages = int(sys.inputs.pages)
#let known = (
  "section",
  "entry",
  "entry-start",
  "entry-continued",
  "skill",
  "honor",
  "publication",
  "document",
)

#assert(items.len() > 0, message: "no <brilliant-cv> elements")
#for item in items {
  assert(item.kind in known, message: "unknown kind: " + repr(item.kind))
  assert(
    type(item.page) == int and item.page >= 1 and item.page <= pages,
    message: "page out of range: " + repr(item),
  )
  for (key, value) in item {
    if key in ("kind", "page", "pages", "level") { continue }
    let ok = (
      type(value) == str
        or (type(value) == array and value.all(v => type(v) == str))
    )
    assert(ok, message: "field is not plain text: " + key + " in " + repr(item))
  }
}
// Hooks are emitted in flow order, so pages never decrease.
#for i in range(1, items.len()) {
  assert(
    items.at(i).page >= items.at(i - 1).page,
    message: "page decreases at " + repr(items.at(i)),
  )
}
#let documents = items.filter(item => item.kind == "document")
#assert.eq(documents.len(), 1, message: "expected exactly one document element")
#assert.eq(items.last().kind, "document", message: "document must come last")
#assert.eq(
  documents.first().pages,
  pages,
  message: "document.pages must equal the PDF page count",
)
