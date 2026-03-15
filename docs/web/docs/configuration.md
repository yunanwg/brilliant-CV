# Configuration Reference — metadata.toml

The `metadata.toml` file is the main configuration file for your CV. By changing the key-value pairs in the config file, you can set up the names, contact information, and other details displayed in your CV.

You can also override the language set in `metadata.toml` via the CLI:

```bash
typst compile cv.typ --input language=fr
```

## Full Example

```toml
# INFO: value must match folder suffix; i.e "zh" -> "./modules_zh"
language = "en"

[layout]
# Optional values: skyblue, red, nephritis, concrete, darknight
awesome_color = "skyblue"

# Skips are for controlling the spacing between sections and entries
before_section_skip = "1pt"
before_entry_skip = "1pt"
before_entry_description_skip = "1pt"

# Font size for the content text
font_size = "9pt"

[layout.header]
# Optional values: left, center, right
header_align = "left"

# Decide if you want to display profile photo or not
display_profile_photo = true
# Radius in % to clip profile photo at
profile_photo_radius = "50%"
profile_photo_path = "template/src/avatar.png"

[layout.entry]
# Decide if you want to put your company in bold or your position in bold
display_entry_society_first = true

# Decide if you want to display organisation logo or not
display_logo = true

[inject]
# Custom AI prompt text (optional). If defined, it will be injected into the CV.
# custom_ai_prompt_text = "Custom prompt text here..."

# Keywords to inject (optional). If defined, they will be injected into the CV.
injected_keywords_list = ["Data Analyst", "GCP", "Python", "SQL", "Tableau"]

[personal]
first_name = "John"
last_name = "Doe"

# The order of this section will affect how the entries are displayed
# The custom value is for any additional information you want to add
[personal.info]
github = "yunanwg"
phone = "+33 6 12 34 56 78"
email = "john.doe@me.org"
linkedin = "johndoe"
# gitlab = "yunanwg"
# homepage = "jd.me.org"
# orcid = "0000-0000-0000-0000"
# researchgate = "John-Doe"
# extraInfo = "I am a cool kid"
# custom-1 = { icon = "", text = "example", link = "https://example.com" }

# Add a new section if you want to include the language of your choice
# i.e. [lang.ru]
# Each section must contain the following fields
[lang.en]
header_quote = "Experienced Data Analyst looking for a full time job starting from now"
cv_footer = "Curriculum vitae"
letter_footer = "Cover letter"

[lang.fr]
header_quote = "Analyste de données expérimenté à la recherche d'un emploi à temps plein disponible dès maintenant"
cv_footer = "Résumé"
letter_footer = "Lettre de motivation"

[lang.zh]
header_quote = "具有丰富经验的数据分析师，随时可入职"
cv_footer = "简历"
letter_footer = "申请信"

# For languages that are not written in Latin script
# Currently supported non-latin language codes: ("zh", "ja", "ko", "ru")
[lang.non_latin]
name = "王道尔"
font = "Heiti SC"
```

## Key Reference

### Root

| Key | Type | Description |
|-----|------|-------------|
| `language` | string | Language code matching your `modules_<lang>/` folder (e.g. `"en"`, `"fr"`, `"zh"`) |

### `[layout]`

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `awesome_color` | string | `"skyblue"` | Accent color. Options: `skyblue`, `red`, `nephritis`, `concrete`, `darknight` |
| `before_section_skip` | string | `"1pt"` | Vertical space before each section |
| `before_entry_skip` | string | `"1pt"` | Vertical space before each entry |
| `before_entry_description_skip` | string | `"1pt"` | Vertical space before entry descriptions |
| `font_size` | string | `"9pt"` | Font size for content text |
| `paper_size` | string | `"a4"` | Paper size (`"a4"` or `"us-letter"`) |

### `[layout.header]`

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `header_align` | string | `"left"` | Header alignment: `left`, `center`, or `right` |
| `display_profile_photo` | bool | `true` | Whether to show the profile photo |
| `profile_photo_radius` | string | `"50%"` | Border radius for clipping the profile photo |
| `profile_photo_path` | string | — | Path to the profile photo image |
| `info_font_size` | string | `"10pt"` | Font size for header info line |

### `[layout.entry]`

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `display_entry_society_first` | bool | `true` | When `true`, company name is bold/first; when `false`, role title is bold/first |
| `display_logo` | bool | `true` | Whether to display organisation logos |

### `[layout.footer]`

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `display_footer` | bool | `true` | Whether to display the footer |
| `display_page_counter` | bool | `false` | Whether to show page numbers in the footer |

### `[inject]`

| Key | Type | Description |
|-----|------|-------------|
| `custom_ai_prompt_text` | string | Custom AI prompt text injected into the CV (optional) |
| `injected_keywords_list` | array | Keywords injected into the CV for ATS optimization (optional) |

### `[personal]`

| Key | Type | Description |
|-----|------|-------------|
| `first_name` | string | Your first name |
| `last_name` | string | Your last name |

### `[personal.info]`

The order of entries in this section affects display order. Supported keys:

| Key | Type | Description |
|-----|------|-------------|
| `github` | string | GitHub username |
| `phone` | string | Phone number |
| `email` | string | Email address |
| `linkedin` | string | LinkedIn username |
| `gitlab` | string | GitLab username |
| `homepage` | string | Personal website URL |
| `orcid` | string | ORCID identifier |
| `researchgate` | string | ResearchGate profile |
| `extraInfo` | string | Any additional text |
| `custom-N` | object | Custom entry with `icon`, `text`, and `link` fields |
| `linebreak` | — | Insert a line break in the header info |

### `[lang.<code>]`

| Key | Type | Description |
|-----|------|-------------|
| `header_quote` | string | Quote/tagline displayed below your name |
| `cv_footer` | string | Footer text for the CV |
| `letter_footer` | string | Footer text for the cover letter |

### `[lang.non_latin]`

| Key | Type | Description |
|-----|------|-------------|
| `name` | string | Your name in non-Latin script |
| `font` | string | Font to use for non-Latin text (e.g. `"Heiti SC"`) |
