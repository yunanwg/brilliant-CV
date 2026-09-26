// Regression: when the body leaves no room for the signature image, the
// signature moves to the next page. It used to be place()d, took no height,
// and ran over the footer or off the page.

#import "/src/lib.typ": letter

#let metadata = toml("/template/profile_en/metadata.toml")

#show: letter.with(
  metadata,
  date: "2026-01-15",
  recipient-name: "Acme Analytics",
  subject: "Subject: Senior Data Scientist application",
  signature: image("/template/assets/signature.png"),
)

#lorem(490)

Sincerely, \
John Doe
