// The supported v4 root API is intentional and regression-tested.

#import "/src/lib.typ": (
  cv, cv-entry, cv-entry-continued, cv-entry-start, cv-honor, cv-publication,
  cv-section, cv-skill, cv-skill-tag, cv-skill-with-level, h-bar, letter,
  overwrite-fonts,
)

#for fn in (
  cv,
  letter,
  cv-section,
  cv-entry,
  cv-entry-start,
  cv-entry-continued,
  cv-skill,
  cv-skill-with-level,
  cv-skill-tag,
  cv-honor,
  cv-publication,
  h-bar,
  overwrite-fonts,
) {
  assert.eq(type(fn), function)
}
