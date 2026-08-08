// Renderer helpers remain user code: call the function and pass its content
// result instead of exposing a package-level callback contract.

#import "/src/lib.typ": cv, h-bar
#import "/tests/common.typ": minimal-metadata

#let render-info(info) = [#info.email #h-bar() Remote]

#show: cv.with(
  minimal-metadata,
  header-info: render-info(minimal-metadata.personal.info),
)

[Body content]
