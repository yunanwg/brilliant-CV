// _get-layout-value eval's the default when the key is absent. Default
// must be a typst-evaluable string per the helper's contract.

#import "/src/cv.typ": _get-layout-value

#assert.eq(_get-layout-value((layout: (:)), "before_entry_skip", "0pt"), 0pt)
#assert.eq(_get-layout-value((layout: (:)), "missing", "2cm"), 2cm)
