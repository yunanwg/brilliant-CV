#import "/docs/book/book.typ": book-page

#show: book-page.with(title: "Setup & Migration")

= Setup

== Step 1: Install Fonts

Install #link("https://fonts.google.com/specimen/Roboto")[Roboto] and #link("https://fonts.google.com/specimen/Source+Sans+3")[Source Sans Pro] on your system.

== Step 2: Bootstrap Template

```bash
typst init @preview/brilliant-cv:<version>
```

== Step 3: Compile

```bash
typst compile cv.typ
```

= Migration from v1 to v2

1. Delete the `brilliant-CV/` folder and `.gitmodules`.
2. Create `metadata.toml` from the example in the repo.
3. Copy the new `cv.typ` and `letter.typ` entry files.
4. In each module file, replace the old import with the new import statements.
5. Update logo arguments: pass `image("logo.png")` instead of `"logo.png"`.
