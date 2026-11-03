# Prototype: CV as data, tailored per job

Exploration only. Nothing here is part of the published package.

| File | Role |
|---|---|
| `resume.json` | The `profile_en` persona as a JSON Resume v1.0.0 document (facts) |
| `json-resume.typ` | Pure-Typst adapter: JSON Resume -> brilliant-cv components, plus tailor selection |
| `applications/acme-ml-engineer.{md,yaml}` | A fictional posting and the tailoring that answers it (choices) |
| `cv.typ` | Entry point; `--input tailor=<file>` switches to a tailored CV |
| `SKILL.md` | Draft agent skill for the tailoring loop |

From the repository root, after `just link`:

```bash
typst compile --root . docs/prototypes/cv-data/cv.typ /tmp/full.pdf
typst compile --root . docs/prototypes/cv-data/cv.typ /tmp/acme.pdf \
  --input tailor=applications/acme-ml-engineer.yaml
```
