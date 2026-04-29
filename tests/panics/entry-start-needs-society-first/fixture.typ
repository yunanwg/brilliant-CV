// expected: display_entry_society_first must be true to use cv-entry-start
//
// Asserts src/cv.typ:770 panics when cv-entry-start is invoked under a
// metadata configuration where display_entry_society_first = false.
// The multi-role start/continued pattern only makes sense when company
// names anchor the entry.

#import "/src/lib.typ": cv
#import "/src/cv.typ": cv-entry-start
#import "/tests/common.typ": metadata-role-first

#show: cv.with(metadata-role-first)

#cv-entry-start(society: [Acme], location: [SF])
