// expected: header-info must be auto, none, a string, or content
//
// A renderer function must be called by the user before it is passed to cv().
// Reject the uncalled function at the public boundary instead of exposing an
// internal callback contract.

#import "/src/lib.typ": cv
#import "/tests/common.typ": minimal-metadata

#show: cv.with(minimal-metadata, header-info: info => [#info.email])

[Body content]
