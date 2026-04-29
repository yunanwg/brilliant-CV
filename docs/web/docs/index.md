# brilliant-CV

[![Typst Universe](https://img.shields.io/badge/Typst_Universe-brilliant--cv-blue?logo=typst&logoColor=white)](https://typst.app/universe/package/brilliant-cv)
[![License](https://img.shields.io/badge/license-Apache_2.0-green.svg)](https://github.com/yunanwg/brilliant-CV/blob/main/LICENSE)
[![Latest release](https://img.shields.io/github/v/release/yunanwg/brilliant-CV?color=orange)](https://github.com/yunanwg/brilliant-CV/releases)

A modern, modular, and feature-rich CV template for [Typst](https://typst.app).

![brilliant-CV Preview](https://github.com/mintyfrankie/mintyfrankie/assets/77310871/94f5fb5c-03d0-4912-b6d6-11ee7d27a9a3){ width="100%" }

!!! info "🆕 v4 is a breaking change"
    Coming from v3? See the [Migration Guide](migration.md) for the v3 → v4 panic-with-migration-message guards (`language`, `non_latin_font`, `[lang.<code>]`, `inject_ai_prompt`, …) and their v4 replacements.

## Features

- **Separation of Style & Content** — Write your CV entries in simple Typst files; the template handles layout and styling.
- **Profile-based Variants** — Each `profile_<name>/` is a complete, self-contained CV. Switch with `--input profile=fr` at compile time. No language whitelist; any script (CJK, Arabic, Hebrew, …) is configurable explicitly via `[layout.fonts]`.
- **AI & ATS Friendly** — Unique "keyword injection" feature to help your CV pass automated screening systems.
- **Highly Customizable** — Tweak colors, fonts, layout, and section highlights via per-profile `metadata.toml` files.
- **Pixel-perfect Tested** — 40+ tests (panic, unit, component, regression) run inside a Linux Docker baseline so refs are deterministic. Layout regressions can't slip past CI.
- **Zero-Setup** — Get started in seconds with the Typst CLI.

## Quick Install

```bash
typst init @preview/brilliant-cv
```

## Gallery

<div class="grid" markdown>

![CV](https://github.com/mintyfrankie/mintyfrankie/assets/77310871/94f5fb5c-03d0-4912-b6d6-11ee7d27a9a3){ data-title="Standard (Skyblue)" }

![CV French](https://github.com/mintyfrankie/brilliant-CV/assets/77310871/fed7b66c-728e-4213-aa58-aa26db3b1362){ data-title="French (Red)" }

![CV Chinese](https://github.com/mintyfrankie/brilliant-CV/assets/77310871/cb9c16f5-8ad7-4256-92fe-089c108d07f5){ data-title="Chinese (Green)" }

</div>

## Where to next?

<div class="grid cards" markdown>

-   :material-rocket-launch: __Build your first CV in 10 minutes__

    Bootstrap a project, edit a profile, compile to PDF.

    [:octicons-arrow-right-24: Getting Started](getting-started.md)

-   :material-puzzle: __Explore the components__

    Every `cv-*` building block with copy-pasteable examples.

    [:octicons-arrow-right-24: Components](components.md)

-   :material-book-open-variant: __Common recipes__

    Profile photos, custom icons, color presets, CI/CD, multi-profile setups.

    [:octicons-arrow-right-24: Recipes](recipes.md)

-   :material-cog: __Configuration reference__

    Every `metadata.toml` field, live-included from `profile_en/`.

    [:octicons-arrow-right-24: Configuration](configuration.md)

-   :material-api: __API reference__

    Function signatures, parameters, and return types.

    [:octicons-arrow-right-24: API Reference](api-reference.md)

-   :material-package-up: __Migrating from v1 / v2 / v3?__

    The v3 → v4 panic-with-migration guards and their replacements.

    [:octicons-arrow-right-24: Migration Guide](migration.md)

</div>
