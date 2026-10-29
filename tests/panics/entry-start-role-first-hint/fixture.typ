// expected: or replace each cv-entry-start and cv-entry-continued group with one cv-entry for each role
//
// Regression for #135: users who set display_entry_society_first = false
// in the starter profile hit this panic from the starter's own
// cv-entry-start group. The message must name both ways out.

#import "/src/lib.typ": cv
#import "/src/cv.typ": cv-entry-continued, cv-entry-start
#import "/tests/common.typ": metadata-role-first

#show: cv.with(metadata-role-first)

#cv-entry-start(society: [Acme], location: [SF])
#cv-entry-continued(title: [Engineer], date: [2020 - Present])
