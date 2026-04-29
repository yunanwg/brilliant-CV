# Tests

Test suite for `brilliant-cv`, powered by [tytanic](https://github.com/typst-community/tytanic).

## Layout

```
tests/
  common.typ                    # shared fixtures (not a tytanic test)
  panics/                       # shell-script smoke tests (not tytanic)
    <name>/fixture.typ          # hand-built v3 metadata input
    run.sh                      # iterate fixtures, assert non-zero exit + stderr substring
  units/<name>/test.typ         # tytanic compile-only — assert.eq() on pure helpers
  components/<name>/test.typ    # tytanic persistent — micro-fixture per public function
  regression/<name>/test.typ    # tytanic persistent — full-profile snapshots
```

Tytanic discovers tests by walking `tests/` for files literally named `test.typ`. Anything else (`common.typ`, `panics/*/fixture.typ`, `panics/run.sh`) is invisible to `tt list` / `tt run`.

## Running

| Command                          | What it does                                                |
| -------------------------------- | ----------------------------------------------------------- |
| `just test`                      | Run the full tytanic suite (panic tests run separately).    |
| `just test-fast`                 | Compile-only tests (panics + units). Sub-second feedback.   |
| `just test-panics`               | Shell-script smoke tests for v3/v2 schema migration panics. |
| `just test-update`               | Regenerate reference PNGs after intentional layout changes. |
| `just test-filter PAT`           | e.g. `just test-filter components/`                         |
| `tt run regression/cv-zh`        | Explicit name bypasses `[skip]` (see CJK note below).       |

## CJK profile tests are skip-annotated

`tests/regression/cv-zh/test.typ` and `tests/regression/letter-zh/test.typ` have a `/// [skip]` annotation so they're filtered out of the default `tt run`. Reason: they require Heiti SC (macOS-default font), which CI Linux runners don't have. Replacing it with Noto Sans CJK in tests would diverge from what real macOS users see, so we instead:

- Skip them in the default suite (CI green path)
- The maintainer regenerates their refs locally on macOS via `tt run regression/cv-zh regression/letter-zh` (explicit name bypasses skip)
- Refs are still committed to git so a regression on macOS is caught at pre-merge time

## Panic tests are not tytanic tests

Tytanic 0.2 has no `expect-panic` annotation — a panicking test is reported as failed. So panic tests live in `tests/panics/<name>/fixture.typ` (a typst file containing v3-style metadata) and are exercised by a small shell script `tests/panics/run.sh` that:

1. Runs `typst compile <fixture.typ>`
2. Asserts the compile fails (non-zero exit)
3. Asserts stderr contains the expected v4 migration substring

The expected substring is encoded in each fixture's first-line comment as `// expected: <substring>`.

## Tolerance

`typst.toml` `[tool.tytanic]` sets `default.max-delta = 10` (per-channel) and `default.max-deviations = 2000` (~0.14% of an A4 144-dpi page). This absorbs subpixel rendering jitter between freetype versions across maintainer macOS and CI Linux. Tighten if regressions slip through; loosen if false positives appear.

## Adding a test

1. Pick the right category — units (pure helpers), components (one public function), regression (full profile), panics (schema migration).
2. `tt new <category>/<name> --compile-only` for unit tests, `tt new <category>/<name> --persistent` for visual regressions.
3. Edit `test.typ`. Use `#import "/src/lib.typ": ...` (root-relative) and `#import "/tests/common.typ": minimal-metadata` for fixtures.
4. For visual regressions, run `tt update <category>/<name>` to generate `ref/*.png`. Inspect manually — if it matches expectation, commit.
5. Run `just test` once before pushing.

## Things that flap pixel diffs

- **`datetime.today()`** — never use it in test fixtures. The `letter()` `date:` arg defaults to today's date; tests must override (`date: "2026-01-01"`).
- **Profile photo `assets/avatar.png`** — bytes change → rasterization changes → diffs flip without layout changes. Component + regression tests omit `profile-photo:`.
- **Font versions** — Source Sans 3, Roboto, Font Awesome 6 must be system-installed for both maintainer and CI. The CI workflow installs them; locally use Homebrew + `font-source-sans-3` / `font-roboto` / `font-fontawesome`.
