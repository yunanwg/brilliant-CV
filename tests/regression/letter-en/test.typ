// Regression: cover letter for the English profile. The `date:` parameter
// must be passed explicitly because letter() defaults to
// datetime.today().display() which would flip the ref every day (see
// src/lib.typ:125).

#import "/src/lib.typ": letter

#let metadata = toml("/template/profile_en/metadata.toml")

#show: letter.with(
  metadata,
  date: "2026-01-15",
  recipient-name: "Acme Analytics",
  recipient-address: [
    Hiring Team \
    100 Market St \
    San Francisco, CA 94105
  ],
  subject: "Subject: Senior Data Scientist application",
)

= Dear Hiring Manager,

This is a sample cover letter body used for visual-regression testing.
It exercises the standard letter layout: header (sender name + address,
recipient block, date, subject), body, and the metadata-driven footer.

I am writing to express my interest in the Senior Data Scientist role.
With over five years of experience in production ML systems, I believe
my background aligns well with the responsibilities outlined in the
posting.

Best regards, \
Jane Doe
