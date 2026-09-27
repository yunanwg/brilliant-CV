// Every CV part registered in _part-names must render with its label, so
// both [layout.parts] and show-set rules reach it. A part added to the
// registry but not wired into a component fails here.

#import "/src/lib.typ": cv
#import "/tests/style-parts.typ": (
  cv-part-names, every-cv-component, every-part-metadata,
)

#show: cv.with(every-part-metadata)
#every-cv-component()

#context for name in cv-part-names {
  assert(
    query(label("bcv-" + name)).len() > 0,
    message: "style part is registered but not rendered: " + name,
  )
}
