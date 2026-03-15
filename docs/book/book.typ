
#import "@preview/shiroa:0.3.1": *

#show: book

#book-meta(
  title: "brilliant-cv",
  summary: [
    #prefix-chapter("introduction.typ")[Introduction]
    #prefix-chapter("setup.typ")[Setup & Migration]
    #prefix-chapter("configuration.typ")[Configuration]
    #prefix-chapter("api-entry.typ")[API: Entry Points]
    #prefix-chapter("api-cv.typ")[API: CV Components]
  ]
)

// re-export page template
#import "/docs/book/templates/page.typ": project
#let book-page = project
