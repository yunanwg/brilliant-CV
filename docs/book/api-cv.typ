#import "/docs/book/book.typ": book-page
#import "@preview/tidy:0.4.2"

#show: book-page.with(title: "API: CV Components")

= API: CV Components

#let cv-docs = tidy.parse-module(read("/src/cv.typ"))
#tidy.show-module(
  cv-docs,
  show-outline: true,
  omit-private-definitions: true,
  omit-private-parameters: true,
)
