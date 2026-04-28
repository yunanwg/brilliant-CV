<h1 align="center">
  <br>
  <img src="thumbnail.png" alt="Brilliant CV Preview" width="100%">
  <br>
  <br>
  Brilliant CV
  <br>
</h1>

<h4 align="center">A modern, modular, and feature-rich CV template for <a href="https://typst.app" target="_blank">Typst</a>.</h4>

## 📖 Documentation

Full documentation (quick start, component gallery, recipes, and API reference) is available online:
**[brilliant-CV Documentation](https://yunanwg.github.io/brilliant-CV/)**

## ✨ Key Features

- **🎨 Separation of Style & Content**: Write your CV entries in simple Typst files, and let the template handle the layout and styling.
- **🌍 Multilingual Support**: Seamlessly switch between languages (English, French, Chinese, etc.) with a single config change.
- **🤖 AI & ATS Friendly**: Unique "keyword injection" feature to help your CV pass automated screening systems.
- **🛠 Highly Customizable**: Tweak colors, fonts, and layout via a simple `metadata.toml` file.
- **📦 Zero-Setup**: Get started in seconds with the Typst CLI.

<br>

## 🚀 How to Use

### 1. Initialize the Project
Run the following command in your terminal to create a new CV project:

```bash
typst init @preview/brilliant-cv
```

### 2. Configure Your CV
Edit the root `metadata.toml` to set shared layout, personal info, and inject options.

### 3. Add Your Content
Each profile lives in its own folder (`profile_en/`, `profile_fr/`, …). Fill in your experience and skills in the `profile_<name>/*.typ` files. The profile's own `metadata.toml` is deep-merged on top of the root, so it only needs the fields that differ (e.g. `header_quote`, `cv_footer`, `[personal.info].location`).

### 4. Compile
Compile your CV to PDF:

```bash
typst compile cv.typ
```

Switch profile at compile time via the CLI:

```bash
typst compile cv.typ --input profile=fr
```

## ⚙️ Configuration

The root `metadata.toml` and each `profile_<name>/metadata.toml` together drive your CV. The profile is sparse and only overrides fields that differ. See the [**Documentation**](https://yunanwg.github.io/brilliant-CV/configuration/) for full details.

| Section | Description |
|---------|-------------|
| `[personal]` | Your name, contact info, and social links. |
| `[layout]` | Margins, fonts, colors, header/footer/entry display. |
| `[inject]` | ATS keyword + custom AI-prompt injection. |
| `header_quote`, `cv_footer`, `letter_footer` | Per-profile localized strings (top-level in profile metadata.toml). |

## 🖼 Gallery

| Style | Preview |
|-------|---------|
| **Standard** | ![CV](https://github.com/mintyfrankie/mintyfrankie/assets/77310871/94f5fb5c-03d0-4912-b6d6-11ee7d27a9a3) |
| **French (Red)** | ![CV French](https://github.com/mintyfrankie/brilliant-CV/assets/77310871/fed7b66c-728e-4213-aa58-aa26db3b1362) |
| **Chinese (Green)** | ![CV Chinese](https://github.com/mintyfrankie/brilliant-CV/assets/77310871/cb9c16f5-8ad7-4256-92fe-089c108d07f5) |

## 🤝 Contributing

Contributions are welcome! Please check out [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## ❤️ Sponsors

> If this template helps you land a job, consider [buying me a coffee](https://github.com/sponsors/yunanwg)! ☕️

<p align="center">
  <!-- sponsors --><a href="https://github.com/GeorgRasumov"><img src="https://github.com/GeorgRasumov.png" width="60px" alt="GeorgRasumov" style="border-radius: 50%;" /></a>&nbsp;&nbsp;<a href="https://github.com/chaoran-chen"><img src="https://github.com/chaoran-chen.png" width="60px" alt="chaoran-chen" style="border-radius: 50%;" /></a>&nbsp;&nbsp;<!-- sponsors -->
</p>

## 📄 License

This project is licensed under the [Apache 2.0 License](LICENSE).
