// Every CV part set to one color through [layout.parts]. Text left in the
// default colors is a part that the metadata does not reach.

#import "/src/lib.typ": cv
#import "/tests/style-parts.typ": every-cv-component, themed-metadata

#show: cv.with(themed-metadata)
#every-cv-component()
