#let hBar() = [#h(5pt) | #h(5pt)]

#let latinFontList = (
  "Source Sans Pro",
  "Source Sans 3",
  "Linux Libertine",
  "Font Awesome 6 Brands",
  "Font Awesome 6 Free",
)

#let latinHeaderFont = ("Roboto")
#let latinFontSize = 10pt

#let awesomeColors = (
  skyblue: rgb("#0395DE"),
  red: rgb("#DC3522"),
  nephritis: rgb("#27AE60"),
  concrete: rgb("#95A5A6"),
  darknight: rgb("#131A28"),
)

#let regularColors = (
  subtlegray: rgb("#ededee"),
  lightgray: rgb("#343a40"),
  darkgray: rgb("#212529"),
)

/// Set the accent color for the document
#let setAccentColor(awesomeColors, metadata) = {
  let param = metadata.layout.awesome_color
  return if param in awesomeColors {
    awesomeColors.at(param)
  } else {
    rgb(param)
  }
}

/// Overwrite the default fonts if the metadata has custom font values
/// 
/// - metadata (dictionary): the metadata object
/// - latinFontList (array): the default list of latin fonts
/// - latinHeaderFont (string): the default header font
/// -> array
#let overwriteFonts(metadata, latinFontList, latinHeaderFont, latinFontSize) = {
  let metadataLayout = metadata.at("layout")
  let metadataFonts = metadataLayout.at("fonts", default: [])
  let regularFonts = latinFontList
  let headerFont = latinHeaderFont
  let fontSize = latinFontSize
  if metadataFonts.len() > 0 {
    regularFonts = metadataFonts.at("regular_fonts")
    headerFont = metadataFonts.at("header_font")
    fontSize = eval(metadataFonts.at("font_size"))
  }
  return (regularFonts: regularFonts, headerFont: headerFont, fontSize: fontSize)
}
