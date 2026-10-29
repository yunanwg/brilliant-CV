// PROTOTYPE entry point. Run from the repository root:
//   typst compile --root . docs/prototypes/cv-data/cv.typ
//   typst compile --root . docs/prototypes/cv-data/cv.typ \
//     --input tailor=applications/acme-ml-engineer.yaml
#import "@preview/brilliant-cv:4.1.1": cv
#import "json-resume.typ": metadata-from-json-resume, render-json-resume

#let data = json("resume.json")
#let tailor = {
  let path = sys.inputs.at("tailor", default: none)
  if path == none { none } else { yaml(path) }
}
// Layout comes from an ordinary profile; personal data comes from the resume.
#let base = toml("/template/profile_en/metadata.toml")
#let logos = (
  "XYZ Corporation": image("/template/assets/logos/xyz_corp.png", alt: "XYZ Corporation logo"),
  "ABC Company": image("/template/assets/logos/abc_company.png", alt: "ABC Company logo"),
  "PQR Corporation": image("/template/assets/logos/pqr_corp.png", alt: "PQR Corporation logo"),
  "Aurora State University": image("/template/assets/logos/aurora_state.png", alt: "Aurora State University logo"),
)

#show: cv.with(
  metadata-from-json-resume(base, data, tailor: tailor),
  profile-photo: image("/template/assets/avatar.png", alt: "Profile photo"),
)

#render-json-resume(data, tailor: tailor, logos: logos)
