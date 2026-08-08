# brilliant-CV

[![Typst Universe](https://img.shields.io/badge/Typst_Universe-brilliant--cv-blue?logo=typst&logoColor=white)](https://typst.app/universe/package/brilliant-cv)
[![License](https://img.shields.io/badge/license-Apache_2.0-green.svg)](https://github.com/yunanwg/brilliant-CV/blob/main/LICENSE)
[![Latest release](https://img.shields.io/github/v/release/yunanwg/brilliant-CV?color=orange)](https://github.com/yunanwg/brilliant-CV/releases)

A modern, modular CV template for [Typst](https://typst.app).

![brilliant-CV Preview](https://github.com/mintyfrankie/mintyfrankie/assets/77310871/94f5fb5c-03d0-4912-b6d6-11ee7d27a9a3){ width="100%" }

!!! info "🆕 v4 is a breaking change"
    If you come from v3, read the [Migration Guide](migration.md). When v4 finds a removed v3 field (`language`, `non_latin_font`, `[lang.<code>]`, `inject_ai_prompt`, and more), it panics with a migration message. The guide gives the v4 replacement for each one.

## Features

- **Separation of Style & Content** — You write your CV entries in simple Typst files. The package applies the layout and the style.
- **Profile-based Variants** — Each `profile_<name>/` directory is one complete CV. To select a profile at compile time, use `--input profile=fr`. There is no language whitelist. You configure any script (CJK, Arabic, Hebrew, and more) explicitly in `[layout.fonts]`.
- **Optional ATS Keyword Injection** — The package can add hidden keyword text for automated screeners. It marks this text as a PDF artifact, so screen readers skip it. The function is off by default, because some screening systems find hidden text and penalize it. Read the `[inject]` notes in `metadata.toml` before you enable it.
- **Highly Customizable** — You set colors, fonts, layout, and section highlights in the `metadata.toml` file of each profile.
- **Pixel-perfect Tested** — More than 40 tests (panic, unit, component, regression) run in a Linux Docker baseline. The refs are deterministic, so CI catches every layout regression.
- **Zero-Setup** — The Typst CLI creates a new project with one command.

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

    Create a project, edit a profile, and compile it to PDF.

    [:octicons-arrow-right-24: Getting Started](getting-started.md)

-   :material-puzzle: __Explore the components__

    Every `cv-*` building block, with examples that you can copy.

    [:octicons-arrow-right-24: Components](components.md)

-   :material-book-open-variant: __Common recipes__

    Profile photos, custom icons, color presets, CI/CD, and multi-profile projects.

    [:octicons-arrow-right-24: Recipes](recipes.md)

-   :material-cog: __Configuration reference__

    Every `metadata.toml` field, included directly from `profile_en/`.

    [:octicons-arrow-right-24: Configuration](configuration.md)

-   :material-api: __API reference__

    Function signatures, parameters, and return types.

    [:octicons-arrow-right-24: API Reference](api-reference.md)

-   :material-package-up: __Migrating from v1 / v2 / v3?__

    The v3 to v4 migration guards and their replacements.

    [:octicons-arrow-right-24: Migration Guide](migration.md)

</div>
