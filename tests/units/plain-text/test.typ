// _plain-text flattens component arguments to strings for the query hooks.
// The shapes below are the ones the shipped profiles pass.

#import "/src/utils/introspect.typ": _plain-text
#import "/src/utils/styles.typ": h-bar

#assert.eq(_plain-text(none), "")
#assert.eq(_plain-text("Plain"), "Plain")
#assert.eq(_plain-text([Director of Data Science]), "Director of Data Science")
#assert.eq(_plain-text([]), "")
#assert.eq(
  _plain-text([2017 - 2020 #linebreak() 2021 - 2022]),
  "2017 - 2020 2021 - 2022",
)
#assert.eq(
  _plain-text(list([Summer 2017], [Summer 2016])),
  "Summer 2017 Summer 2016",
)
#assert.eq(_plain-text([Python #h-bar() SQL]), "Python | SQL")
#assert.eq(_plain-text(strong[AWS]), "AWS")
#assert.eq(_plain-text(link("https://example.com")[Site]), "Site")
#assert.eq(_plain-text(image("/template/assets/avatar.png")), "")
#assert.eq(_plain-text(4), "4")
