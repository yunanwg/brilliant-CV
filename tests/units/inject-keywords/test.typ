// _inject with only injected_keywords_list (the v3+ canonical case) —
// keywords get joined with spaces and rendered as 2pt white text via place().

#import "/src/utils/injection.typ": _compose-injection-text, _inject

#assert.eq(
  _compose-injection-text(keywords: ("Python", "SQL", "Tableau")),
  "Python SQL Tableau",
)
#assert.ne(_inject(keywords: ("Python", "SQL", "Tableau")), [])
