// A plain string is a supported lightweight override for the header info row.

#import "/src/lib.typ": cv
#import "/tests/common.typ": minimal-metadata

#show: cv.with(minimal-metadata, header-info: "jane.doe@example.com")

[Body content]
