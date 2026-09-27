// Every letter part set to one color through [layout.parts]. The body text
// is not a part and keeps its default color.

#import "/src/lib.typ": letter
#import "/tests/style-parts.typ": themed-metadata

#show: letter.with(
  themed-metadata,
  date: "2026-01-15",
  recipient-name: "Acme Analytics",
  recipient-address: "100 Market St",
  subject: "Application",
)

Body.
