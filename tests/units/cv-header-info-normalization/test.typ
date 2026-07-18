// Empty values and linebreak sentinels cannot create dangling separators.

#import "/src/cv.typ": _normalize-header-info

#let rows = _normalize-header-info((
  empty-first: "",
  email: "jane@example.com",
  empty-middle: "",
  github: "janedoe",
  linebreak: "",
  location: "Remote",
  empty-last: "",
))

#assert.eq(rows.len(), 2)
#assert.eq(rows.at(0).map(pair => pair.at(0)), ("email", "github"))
#assert.eq(rows.at(1).map(pair => pair.at(0)), ("location",))
#assert.eq(_normalize-header-info((linebreak: "", email: "x@y.z")).len(), 1)
#assert.eq(_normalize-header-info((email: "x@y.z", linebreak: "")).len(), 1)

#let custom-rows = _normalize-header-info((
  custom-empty: (awesomeIcon: "", text: "", link: ""),
  custom-visible: (awesomeIcon: "certificate", text: "Certified", link: ""),
))
#assert.eq(custom-rows.len(), 1)
#assert.eq(custom-rows.at(0).map(pair => pair.at(0)), ("custom-visible",))
