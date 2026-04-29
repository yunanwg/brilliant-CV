# Tests

Test suite for `brilliant-cv`, powered by [tytanic](https://github.com/typst-community/tytanic). All visual tests run inside a Linux Docker image (`tests/Dockerfile`) on **both** maintainer machines and CI, so reference PNGs are pixel-deterministic — no cross-OS antialiasing differences to absorb. Tolerance is `max-delta=1, max-deviations=0` (perfect match required).

## Layout

```
tests/
  Dockerfile                    # Test environment (typst, tytanic, typstyle, fonts)
  docker-entrypoint.sh          # Registers /workspace as @preview/brilliant-cv:<v>
  common.typ                    # Shared fixtures (not a tytanic test)
  panics/                       # Shell-script smoke tests (not tytanic)
    <name>/fixture.typ          # Hand-built v3/v2 metadata input
    run.sh                      # Iterate fixtures, assert non-zero exit + stderr substring
  units/<name>/test.typ         # Tytanic compile-only — assert.eq() on pure helpers
  components/<name>/test.typ    # Tytanic persistent — micro-fixture per public function
  regression/<name>/test.typ    # Tytanic persistent — full-profile snapshots
```

Tytanic discovers tests by walking `tests/` for files literally named `test.typ`. Anything else (`common.typ`, `panics/*/fixture.typ`, `panics/run.sh`, `Dockerfile`) is invisible to `tt list` / `tt run`.

## Running

| Command                       | Where                  | What it does                                                    |
| ----------------------------- | ---------------------- | --------------------------------------------------------------- |
| `just test`                   | Docker (`linux/amd64`) | Full suite — tytanic visual + panic shell smoke tests           |
| `just test-fast`              | native (host shell)    | Panic + unit tests only (compile-only, sub-second)              |
| `just test-panics`            | native                 | Just the panic-fixture shell script                             |
| `just test-filter '<glob>'`   | Docker                 | Visual tests matching a tytanic glob, e.g. `'components/*'`     |
| `just test-update`            | Docker                 | Regenerate ref PNGs after intentional layout changes            |
| `just test-image`             | (docker build)         | Build / refresh the test image (cached after first run)         |
| `just test-shell`             | Docker (interactive)   | Drop into a shell inside the image for debugging                |
| `just fmt-check`              | Docker                 | typstyle gate (matches CI version pin exactly)                  |

The first `just test` invocation builds the Docker image (~3 min — typst + tytanic + typstyle + fonts). Subsequent runs use the cached image (~2 s container startup overhead).

### Why Docker?

macOS and Linux render text with different antialiasing engines (CoreText vs freetype/harfbuzz). Without containerization, you have two bad options:

1. **Loose tolerance** to absorb cross-OS noise (we tried this — see git log, max-delta=50 was needed). 25× looser than ideal, hides real regressions.
2. **Per-OS refs** with `ref/`, `ref-macos/`, `ref-linux/` — tytanic doesn't natively support multiple ref dirs, requires hacky path swapping.

Docker gives **one source of truth**: `tt run` produces byte-identical pixels on every machine, so `max-delta=1, max-deviations=0` is achievable.

## CJK profile tests

`profile_zh` ships with `Heiti SC` (macOS-default, not freely redistributable). The Linux Docker image installs `fonts-noto-cjk` instead, and the test fixtures (`regression/cv-zh/test.typ`, `regression/letter-zh/test.typ`) override `[layout.fonts]` to use Noto Sans CJK SC. The tests verify "mixed-script profile renders without errors and the layout is stable" — they do not verify "Heiti SC visually matches" (that's a font-choice concern, checked by the maintainer manually with `just dev`).

## Panic tests are not tytanic tests

Tytanic has no `expect-panic` annotation — a panicking test is reported as failed. Panic tests live in `tests/panics/<name>/fixture.typ` and are exercised by `tests/panics/run.sh`:

1. Runs `typst compile --root . <fixture>`
2. Asserts compile fails (non-zero exit)
3. Asserts stderr contains the expected v4 migration substring

The expected substring is encoded in each fixture's first-line comment as `// expected: <substring>`. Panic tests run native (not in Docker) because they only exercise typst error messages — no rendering involved, OS-independent.

## Adding a test

1. Pick the category — `units` (pure helpers), `components` (one public function), `regression` (full profile), `panics` (schema migration).
2. Visual test? `just test-shell` then inside the container `tt new <category>/<name> --persistent --no-template`. Compile-only? `tt new <category>/<name> --compile-only`.
3. Edit `test.typ`. Use `#import "/src/lib.typ": ...` (root-relative) and `#import "/tests/common.typ": minimal-metadata` for fixtures.
4. For visual regressions, `just test-update` to generate `ref/*.png`. Inspect manually — if it matches expectation, commit.
5. Run `just test` once before pushing.

## Things that flap pixel diffs

- **`datetime.today()`** — never in test fixtures. The `letter()` `date:` arg defaults to today's date; tests must override (`date: "2026-01-01"`).
- **Profile photo `assets/avatar.png`** — bytes change → rasterization changes → diff flips without layout changes. Component + regression tests omit `profile-photo:`.
- **Dockerfile changes** — bumping a font / binary version changes rendering. Always regenerate refs (`just test-update`) in the same commit.

## Native-only inner loop

If you have `tytanic` and `typstyle` installed natively (`cargo install tytanic --version "^0.3"` + `brew install typstyle`), `just test-fast` exercises the OS-independent subset (panics + units) at sub-second speed — useful while iterating. Visual tests still need Docker.
