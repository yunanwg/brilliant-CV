// cv-entry with display_entry_society_first = false — role bold on top,
// company below. Inverted from the conventional layout.

#import "/src/cv.typ": cv-entry, cv-metadata
#import "/src/utils/styles.typ": _latin-font-list, _regular-colors
#import "/tests/common.typ": metadata-role-first

#set page(width: 16cm, height: auto, margin: 0.5cm)
#set text(font: _latin-font-list, size: 9pt, fill: _regular-colors.lightgray)
#cv-metadata.update(metadata-role-first)

#cv-entry(
  title: [Data Engineer],
  society: [Initech],
  date: [2018 -- 2020],
  location: [Austin, TX],
  description: [Built and maintained the company-wide data warehouse on Snowflake.],
)
