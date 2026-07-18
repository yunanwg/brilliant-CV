// Empty injection has no layout side effects.

#import "/src/utils/injection.typ": _compose-injection-text, _inject

#assert.eq(_compose-injection-text(), "")
#assert.eq(
  _compose-injection-text(custom-ai-prompt-text: none, keywords: ()),
  "",
)
#assert.eq(_inject(), [])
