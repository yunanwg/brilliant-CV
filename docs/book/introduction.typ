#import "/docs/book/book.typ": book-page

#show: book-page.with(title: "Introduction")

= Introduction

Brilliant CV is a Typst template for making Résumés, CVs, and Cover Letters, inspired by the popular LaTeX template #link("https://github.com/posquit0/Awesome-CV")[Awesome-CV].

== Features

- *Modular*: Split your CV into multiple files per section (work, education, projects…)
- *Multilingual*: Switch languages by changing one line in `metadata.toml`
- *Configurable*: All styling controlled from a single `metadata.toml`
- *Cover letter*: Included letter template that shares the same styling

== Quick Start

```bash
typst init @preview/brilliant-cv:<version>
```

Then adapt `metadata.toml` and compile:

```bash
typst compile cv.typ
```
