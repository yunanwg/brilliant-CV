#let isNonLatin(lang) = {
  let nonLatinLanguageCode = ("zh", "ja", "ko", "ru")
  return nonLatinLanguageCode.contains(lang)
}

#let dateWidth(lang) = {
  return if lang == "en" {
    3.6cm
  } else if lang == "fr" {
    3.4cm
  } else if lang == "zh" {
    4.7cm
  } else if lang == "it" {
    3.9cm
  } else {
    panic("Unsupported language")
  }
}
