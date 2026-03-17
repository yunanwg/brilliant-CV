// Imports
#import "@preview/brilliant-cv:3.2.0": cv, deep-merge
#let metadata = toml("./metadata.toml")

// Profile override: deep-merge a sparse profile TOML on top of root config.
// Override via CLI: typst compile cv.typ --input profile=fr
#let cv-profile = sys.inputs.at("profile", default: metadata.at("profile", default: none))
#let metadata = if cv-profile != none {
  deep-merge(metadata, toml("./profiles/" + cv-profile + ".toml"))
} else {
  metadata
}

// Backward compat: --input language=xx still works as a final override
#let cv-language = sys.inputs.at("language", default: none)
#let metadata = if cv-language != none {
  metadata + (language: cv-language)
} else {
  metadata
}

#let import-modules(modules, lang: metadata.language) = {
  for module in modules {
    include {
      "modules_" + lang + "/" + module + ".typ"
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

#import-modules((
  "education",
  "professional",
  "projects",
  "certificates",
  "publications",
  "skills",
))
