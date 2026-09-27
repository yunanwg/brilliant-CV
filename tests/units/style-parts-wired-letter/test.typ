// Every letter part registered in _part-names must render with its label.

#import "/src/lib.typ": letter
#import "/tests/style-parts.typ": every-part-metadata, letter-part-names

#show: letter.with(
  every-part-metadata,
  date: "2026-01-15",
  recipient-name: "Acme Analytics",
  recipient-address: "100 Market St",
  subject: "Application",
)

Body.

#context for name in letter-part-names {
  assert(
    query(label("bcv-" + name)).len() > 0,
    message: "style part is registered but not rendered: " + name,
  )
}
