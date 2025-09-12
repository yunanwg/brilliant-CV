
#let h-bar() = [#h(5pt) | #h(5pt)]

#let latin-font-list = (
  "Source Sans 3",
  "Linux Libertine",
  "Font Awesome 6 Brands",
  "Font Awesome 6 Free",
)

#let latin-header-font = ("Roboto")

#let awesome-colors = (
  skyblue: rgb("#0395DE"),
  red: rgb("#DC3522"),
  nephritis: rgb("#27AE60"),
  concrete: rgb("#95A5A6"),
  darknight: rgb("#131A28"),
)

#let regular-colors = (
  subtlegray: rgb("#ededee"),
  lightgray: rgb("#343a40"),
  darkgray: rgb("#212529"),
)

/// Set the accent color for the document
/// 
/// - awesomeColors (array): the awesome colors
/// - metadata (array): the metadata object
/// -> color
#let set-accent-color(awesomeColors, metadata) = {
  let param = metadata.layout.awesome_color
  return if param in awesomeColors {
    awesomeColors.at(param)
  } else {
    rgb(param)
  }
}

/// Overwrite the default fonts if the metadata has custom font values
/// 
/// - metadata (array): the metadata object
/// - latinFontList (array): the default list of latin fonts
/// - latinHeaderFont (string): the default header font
/// -> array
#let overwrite-fonts(metadata, latinFontList, latinHeaderFont) = {
  let metadataFonts = metadata.layout.at("fonts", default: [])
  let regularFonts = latinFontList
  let headerFont = latinHeaderFont
  if metadataFonts.len() > 0 {
    regularFonts = metadataFonts.at("regular_fonts")
    headerFont = metadataFonts.at("header_font")
  }
  return (regularFonts: regularFonts, headerFont: headerFont)
}

// Backward compatibility aliases
#let setAccentColor = set-accent-color
#let overwriteFonts = overwrite-fonts
#let hBar = h-bar
#let latinFontList = latin-font-list
#let latinHeaderFont = latin-header-font
#let awesomeColors = awesome-colors
#let regularColors = regular-colors
