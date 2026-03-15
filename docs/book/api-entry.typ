#import "/docs/book/book.typ": book-page
#import "@preview/tidy:0.4.2"

#show: book-page.with(title: "API: Entry Points")

= API: Entry Points

These are the two top-level functions exported by the package, used in `cv.typ` and `letter.typ`.

#let lib-docs = tidy.parse-module(read("/src/lib.typ"))
#tidy.show-module(
  lib-docs,
  show-outline: true,
  omit-private-definitions: true,
  omit-private-parameters: true,
)
