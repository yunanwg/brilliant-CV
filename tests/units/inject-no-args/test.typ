// _inject called with all defaults (no prompt, no keywords) compiles
// without error and produces an empty injection. Smoke test — the helper
// returns content via place(), so we can't assert.eq on its value.

#import "/src/utils/injection.typ": _inject

#_inject()
#_inject(custom-ai-prompt-text: none, keywords: ())
