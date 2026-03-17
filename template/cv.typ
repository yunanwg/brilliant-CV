// Imports
#import "@preview/brilliant-cv:3.2.0": cv, deep-merge

// Load shared root config, then deep-merge with profile-specific overrides.
// Override via CLI: typst compile cv.typ --input profile=fr
#let profile = sys.inputs.at("profile", default: "en")
#let metadata = deep-merge(
  toml("./metadata.toml"),
  toml("profile_" + profile + "/metadata.toml"),
)

#let import-modules(modules) = {
  for module in modules {
    include {
      "profile_" + profile + "/" + module + ".typ"
    }
  }
}

#show: cv.with(
  metadata,
  profile-photo: image("assets/avatar.png"),
  // To use custom image icons in personal.info.custom-N entries,
  // pass them here (keys must match the custom-N keys in metadata.toml):
  // custom-icons: (
  //   "custom-1": image("assets/my-icon.png"),
  // ),
)

// Add, remove, or reorder modules to customize your CV content
#import-modules((
  "education",
  "professional",
  "projects",
  "certificates",
  "publications",
  "skills",
))
