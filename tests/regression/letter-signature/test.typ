// Regression: a signature image on a letter whose body leaves room for it.
// The signature sits right-aligned below the closing, at the same position
// as the historical place()-based layout.

#import "/src/lib.typ": letter

#let metadata = toml("/template/profile_en/metadata.toml")

#show: letter.with(
  metadata,
  date: "2026-01-15",
  recipient-name: "Acme Analytics",
  subject: "Subject: Senior Data Scientist application",
  signature: image("/template/assets/signature.png"),
)

#lorem(300)

Sincerely, \
John Doe
