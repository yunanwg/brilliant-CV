<h1 align="center">
  <img src='https://github.com/mintyfrankie/mintyfrankie/assets/77310871/64861d2d-971c-47cd-a5e8-5ad8659f2c2b'>
  <br><br>
  Brilliant CV
</h1>

<p align="center">
  <img alt="Check Status Badge" src="https://github.com/mintyfrankie/brilliant-CV/actions/workflows/compile.yml/badge.svg"/>
  <img alt="Typst Version" src="https://img.shields.io/badge/Compatible Typst Version-0.11.0-blue"/>
</p>

<br>

> If my work helps you drift through tedious job seeking journey, don't hesitate to think about [buying me a Coke Zero](https://github.com/sponsors/mintyfrankie)... or a lot of them! 🥤



**Brilliant CV** is a [**Typst**](https://github.com/typst/typst) template for making **Résume**, **CV** or **Cover Letter** inspired by the famous LaTeX CV template [**Awesome-CV**](https://github.com/posquit0/Awesome-CV).

## Features

**1. Separation of style and content**

> Version control your CV entries in the `modules` folder, without touching the styling and typesetting of your CV / Cover Letter _(hey, I am not talking about **Macrohard Word**, you know)_

**2. Quick twitches on the visual**

> Add company logos, put your shiny company name or your coolest title at the first line globally or per-document needs

**3. Multilingual support**

> Centrally store your multilingual CVs (English + French + German + Chinese + Japanese if you are superb) and change output language in a blink

***(NEW)* 4. AI Prompt and Keywords Injection**

> Fight against the abuse of ATS system or GenAI screening by injecting invisible AI prompt or keyword list automatically.

## Preview

|                                                    CV                                                    |                                                    Cover Letter                                                    |
| :------------------------------------------------------------------------------------------------------: | :----------------------------------------------------------------------------------------------------------------: |
| ![CV](https://github.com/mintyfrankie/mintyfrankie/assets/77310871/94f5fb5c-03d0-4912-b6d6-11ee7d27a9a3) | ![Cover Letter](https://github.com/mintyfrankie/brilliant-CV/assets/77310871/b4e74cdd-6b8d-4414-b52f-13cd6ba94315) |

|                                       CV (_French, red, no photo_)                                       |                                            Cover Letter (_French, red_)                                            |
| :------------------------------------------------------------------------------------------------------: | :----------------------------------------------------------------------------------------------------------------: |
| ![CV](https://github.com/mintyfrankie/brilliant-CV/assets/77310871/fed7b66c-728e-4213-aa58-aa26db3b1362) | ![Cover Letter](https://github.com/mintyfrankie/brilliant-CV/assets/77310871/65ca65b0-c0e1-4fe8-b797-8a5e0bea4b1c) |

|                                       CV (_Chinese, green_)                                       |                                            Cover Letter (_Chinese, green_)                                            |
| :------------------------------------------------------------------------------------------------------: | :----------------------------------------------------------------------------------------------------------------: |
| ![CV](https://github.com/mintyfrankie/brilliant-CV/assets/77310871/cb9c16f5-8ad7-4256-92fe-089c108d07f5) | ![Letter](https://github.com/mintyfrankie/brilliant-CV/assets/77310871/a5a97be2-87e2-43fe-b605-f862a0d600d7)|


## Usage

### Installation

You can either directly create a new repository by using this template, or you might want to add the submodule repository and build up your own Typst project.

**Method 1: Jumpstart by clicking `Use this template` and create your own CV repository**

When compiling, use:

```
typst compile ./cv.typ ./output/CV.pdf --font-path ./src/fonts/
```

**Method 2: Add the [submodule repository](https://github.com/mintyfrankie/brilliant-CV-Submodule) to your existing project**

```bash
cd your/CV/project
git submodule add https://github.com/mintyfrankie/brilliant-CV-Submodule brilliant-CV
typst compile cv.typ
```

When you want to get new features from the updated template module:

```bash
git submodule update --remote
```

### Tips

- `metadata.typ` should live in the project root folder, and by changing the variables in it, you can quickly adjust language or display settings of the documents.
- Make sure when you build a multilingual module (`./modules_fr` for example) you are quoting the right language variable in the `metadata.typ` (`fr` in this case).

### Project Structure

```
|
|-- modules_en/          --> sections of your CV
|   |- *.typ
|
|-- modules_*         --> multilingual sections of your CV
|
|-- brilliant-CV/
|   |- template.typ   --> the template file
|   |- metadata-demo.typ -> the example metadata file
|
|-- src/
|   |- fonts/         --> local font files
|   |- logos/         --> logos for your cvEntry
|   |- *.png          --> images used in the documents
|   |- *.bib          --> BibTeX file for Publications section
|
|-- cv.typ          --> CV file
|-- letter.typ      --> Cover Letter file
|-- metadata.typ    --> Personal Infos & Settings
```


## Current Issues

> As Typst is still a very young (although very promising and robust to my belief) project, some features are only partially supported on certain platforms. It is hence difficult to predict any anomalies, but you are definitely welcomed to bring a PR, an issue or a discussion!

- **Publications Section**: Current version of Typst does not allow full customization on the `#bibliography` function, so the display of publication section might not be optimal. See [this disucssion](https://github.com/typst/typst/issues/942).

## Credit

- [**Typst**](https://github.com/typst/typst) is a newborn, open source and simple typesetting engine that offers a better scripting experience than [**LaTeX**](https://www.latex-project.org/).
- [**Awesome-CV**](https://github.com/posquit0/Awesome-CV) is the original LaTeX CV template from which this project is heavily inspired. Thanks [posquit0](https://github.com/posquit0) for your excellent work!
