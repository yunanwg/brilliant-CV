// Imports
#import "@preview/brilliant-cv:2.0.6": cv
#let metadata = toml("./metadata.toml")

#let import-modules(modules, lang: metadata.language) = {
  for module in modules {
    include {
      "modules_" + lang + "/" + module + ".typ"
    }
  }
}

#show: cv.with(
  metadata,
  profilePhoto: image("./src/avatar.png"),
)

#import-modules((
  "education",
  "professional",
  "projects",
  // "certificates",
  "publications",
  "skills",
))
