// The contact row at many widths, with and without a profile photo, one
// page each. tests/text/run.sh extracts the text and fails if any contact
// line ends with a separator: packing that misjudges a line's width only
// shows at some widths, so a single fixed layout can miss it.

#import "/src/lib.typ": _resolve-typography
#import "/src/cv.typ": _cv-header
#import "/src/utils/styles.typ": _awesome-colors, _regular-colors
#import "/tests/common.typ": minimal-metadata

#let base = (
  ..minimal-metadata,
  header_quote: none,
  personal: (
    ..minimal-metadata.personal,
    info: (
      phone: "+1 (415) 555-0132",
      email: "john.doe@me.org",
      homepage: "johndoe.dev",
      github: "yunanwg",
      orcid: "0000-0000-0000-0000",
      location: "San Francisco, CA",
      linkedin: "johndoe",
      custom-degree: (
        awesomeIcon: "graduation-cap",
        text: "Master of Data Science",
      ),
      custom-cert: (awesomeIcon: "certificate", text: "AWS Certified"),
    ),
  ),
)

#let typography = _resolve-typography(base)
#set text(font: typography.regular-fonts, size: typography.font-size)

#for photo in (false, true) {
  let metadata = (
    ..base,
    layout: (
      ..base.layout,
      header: (..base.layout.header, display_profile_photo: photo),
    ),
  )
  for step in range(45) {
    page(
      width: 9cm + step * 0.25cm + 2cm,
      height: auto,
      margin: 1cm,
      _cv-header(
        metadata,
        image("/template/assets/avatar.png"),
        typography.header-font,
        _regular-colors,
        _awesome-colors,
        (:),
        auto,
      ),
    )
  }
}
