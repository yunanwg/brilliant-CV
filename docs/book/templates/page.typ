// This is important for shiroa to produce a responsive layout
// and multiple targets.
#import "@preview/shiroa:0.3.1": (
  get-page-width, is-html-target, is-pdf-target, is-web-target, plain-text, shiroa-sys-target, templates,
)
#import templates: *

/// The site theme to use. If we renders to static HTML, it is suggested to use `starlight`.
/// otherwise, since `starlight` with dynamic SVG HTML is not supported, `mdbook` is used.
/// The `is-html-target(exclude-wrapper: true)` is currently a bit internal so you shouldn't use it other place.
#let web-theme = if is-html-target(exclude-wrapper: true) { "starlight" } else { "mdbook" }
#let is-starlight-theme = web-theme == "starlight"

// Metadata
#let page-width = get-page-width()
#let is-html-target = is-html-target()
#let is-pdf-target = is-pdf-target()
#let is-web-target = is-web-target()
#let sys-is-html-target = ("target" in dictionary(std))

// Theme (Colors)
#let themes = theme-box-styles-from(toml("theme-style.toml"), read: it => read(it))
#let (
  default-theme: (
    style: theme-style,
    is-dark: is-dark-theme,
    is-light: is-light-theme,
    main-color: main-color,
    dash-color: dash-color,
    code-extra-colors: code-extra-colors,
  ),
) = themes;
#let (
  default-theme: default-theme,
) = themes;
#let theme-box = theme-box.with(themes: themes)

// Fonts
#let main-font = (
  "Charter",
  "Source Han Serif SC",
  // "Source Han Serif TC",
  // shiroa's embedded font
  "Libertinus Serif",
)
#let code-font = (
  "BlexMono Nerd Font Mono",
  // shiroa's embedded font
  "DejaVu Sans Mono",
)

// Sizes
#let main-size = if is-web-target {
  16pt
} else {
  10.5pt
}
#let heading-sizes = if is-web-target {
  (2, 1.5, 1.17, 1, 0.83).map(it => it * main-size)
} else {
  (26pt, 22pt, 14pt, 12pt, main-size)
}
#let list-indent = 0.5em

// Put your custom CSS here.
#let extra-css = ```css
.site-title {
  font-size: 1.2rem;
  font-weight: 600;
  font-style: italic;
}
```

/// The project show rule that is used by all pages.
///
/// Example:
/// ```typ
/// #show: project
/// ```
///
/// - title (str): The title of the page.
/// - description (auto): The description of the page.
///   - If description is `auto`, it will be generated from the plain body.
///   - If description is `none`, an error is raised to force migration. In future, `none` will mean the description is not generated.
///   - Hint: use `""` to generate an empty description.
/// - authors (array | str): The author(s) of the page.
/// - kind (str): The kind of the page.
/// - plain-body (content): The plain body of the page.
#let project(title: "Typst Book", description: auto, authors: (), kind: "page", plain-body) = {
  // set basic document metadata
  set document(
    author: authors,
    title: title,
  ) if not is-pdf-target

  // set web/pdf page properties
  set page(
    numbering: none,
    number-align: center,
    width: page-width,
  ) if not (sys-is-html-target or is-html-target)

  // remove margins for web target
  set page(
    margin: (
      // reserved beautiful top margin
      top: 20pt,
      // reserved for our heading style.
      // If you apply a different heading style, you may remove it.
      left: 20pt,
      // Typst is setting the page's bottom to the baseline of the last line of text. So bad :(.
      bottom: 0.5em,
      // remove rest margins.
      rest: 0pt,
    ),
    height: auto,
  ) if is-web-target and not is-html-target

  let common = (
    web-theme: web-theme,
  )

  show: template-rules.with(
    book-meta: include "/docs/book/book.typ",
    title: title,
    description: description,
    plain-body: plain-body,
    extra-assets: (extra-css,),
    ..common,
  )

  // Set main text
  set text(
    font: main-font,
    size: main-size,
    fill: main-color,
    lang: "en",
  )

  // markup setting
  show: markup-rules.with(
    ..common,
    themes: themes,
    heading-sizes: heading-sizes,
    list-indent: list-indent,
    main-size: main-size,
  )
  // math setting
  show: equation-rules.with(..common, theme-box: theme-box)
  // code block setting
  show: code-block-rules.with(..common, themes: themes, code-font: code-font)

  // Main body.
  set par(justify: true)

  plain-body
}

#let part-style = heading
