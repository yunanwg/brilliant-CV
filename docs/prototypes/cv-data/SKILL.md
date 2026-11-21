---
name: tailor-cv
description: Tailor a brilliant-cv resume to one job posting. Use when the user pastes or links a job description and wants a CV (and optionally a cover letter) for it.
---

# Tailor a CV to a job posting

Facts live in `resume.json`. A tailoring is one file,
`applications/<slug>.yaml`, that selects and orders those facts. You never
write a fact into the tailoring file.

## Steps

1. Save the posting as `applications/<slug>.md`, verbatim.
2. Extract the requirements: must-have skills, nice-to-have skills, seniority,
   domain words. Keep the posting's own wording.
3. Map each requirement to evidence in `resume.json` by `id` and highlight
   index. A requirement without evidence goes to the gap list. Do not cover
   it with a rephrased highlight.
4. Write `applications/<slug>.yaml`:
   - `label`: one line that the evidence supports.
   - `sections`: the order that puts the strongest evidence first.
   - per section, the items and highlight indices to keep, strongest first.
   - `keywords`: only words that appear both in the posting and in `resume.json`.
5. Compile: `typst compile --root . cv.typ --input tailor=applications/<slug>.yaml`.
   An unknown id or index fails the build: fix the reference, not the guard.
6. Check the page count with the `<brilliant-cv>` query (see the package's
   `cv()` doc-comment). Cut the weakest highlights until the CV fits the
   target length.
7. Report to the user, in this order: the gap list, what you left out and
   why, and the path of the PDF.

## When the user adds a fact

Edit `resume.json` (give the new item an `id`), then re-run step 3. Every
tailoring that exists can use the new fact.
