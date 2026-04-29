// expected: display_entry_society_first must be true to use cv-entry-continued
//
// Asserts src/cv.typ:810 panics when cv-entry-continued is invoked under a
// metadata configuration where display_entry_society_first = false.

#import "/src/lib.typ": cv
#import "/src/cv.typ": cv-entry-continued
#import "/tests/common.typ": metadata-role-first

#show: cv.with(metadata-role-first)

#cv-entry-continued(title: [Data Scientist], date: [2024])
