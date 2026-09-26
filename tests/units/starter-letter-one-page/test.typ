// The starter cover letter must fit on one page: its closing block
// (closing, signature, name) is unbreakable, so any extra body text moves
// the whole block to a second page in every freshly initialized starter.

#include "/template/letter.typ"

#context assert.eq(
  counter(page).final().first(),
  1,
  message: "template/letter.typ no longer fits on one page",
)
