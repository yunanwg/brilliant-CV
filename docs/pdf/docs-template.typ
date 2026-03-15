#let template(
  title: "",
  subtitle: "",
  authors: "",
  date: "",
  version: "",
  doc,
) = {
  import "@preview/codly:1.2.0": *
  set document(author: authors, title: title)
  set page(numbering: "1", number-align: center)
  set text(font: "Source Sans 3", lang: "en")
  show link: set text(fill: rgb("#1e8f6f"))
  show link: underline

  show: codly-init.with()

  align(
    center,
    text(17pt, weight: "bold")[
      #title

      #subtitle
    ],
  )

  h(10pt)

  align(
    center,
    rect[
      _Authors: #authors _

      _Build Date: #datetime.today().display()_

      _Version: #version _
    ],
  )

  outline(depth: 2)

  pagebreak()

  doc
}

#let tip-box(body) = {
  block(
    width: 100%,
    inset: 10pt,
    radius: 4pt,
    fill: rgb("#e8f4e8"),
    stroke: rgb("#27AE60") + 1pt,
    body,
  )
}

#let warning-box(body) = {
  block(
    width: 100%,
    inset: 10pt,
    radius: 4pt,
    fill: rgb("#fff3e0"),
    stroke: rgb("#DC3522") + 1pt,
    body,
  )
}
