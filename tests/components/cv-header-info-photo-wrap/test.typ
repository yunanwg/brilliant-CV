// With a profile photo, the header column shrinks to the widest packed
// contact line, so the packing must measure lines exactly: a separator
// measured on its own loses its spaces, and the underestimate wrapped a
// line inside its box and left a stray `|` at its end.

#import "/src/lib.typ": cv
#import "/tests/common.typ": minimal-metadata

#let metadata = (
  ..minimal-metadata,
  header_quote: none,
  layout: (
    ..minimal-metadata.layout,
    header: (..minimal-metadata.layout.header, display_profile_photo: true),
  ),
  personal: (
    ..minimal-metadata.personal,
    info: (
      phone: "+1 (415) 555-0132",
      email: "john.doe@me.org",
      homepage: "johndoe.dev",
      orcid: "0000-0000-0000-0000",
      location: "San Francisco, CA",
      custom-github: (
        awesomeIcon: "github",
        text: "github.com/yunanwg",
        link: "https://github.com/yunanwg",
      ),
      custom-degree: (
        awesomeIcon: "graduation-cap",
        text: "Master of Data Science",
      ),
      custom-cert: (awesomeIcon: "certificate", text: "AWS Certified"),
      custom-linkedin: (
        awesomeIcon: "linkedin",
        text: "linkedin.com/in/johndoe",
        link: "https://www.linkedin.com/in/johndoe",
      ),
    ),
  ),
)

// A plain shape stands in for the photo: the layout only needs the photo
// column, and avatar.png bytes would flap the ref (tests/README.md).
#show: cv.with(
  metadata,
  profile-photo: rect(width: 3.6cm, height: 3.6cm, fill: luma(200)),
)
