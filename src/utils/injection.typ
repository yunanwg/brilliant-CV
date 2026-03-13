/*
A module containing the injection logic for the AI prompt and keywords.
*/

#let _inject(
  custom-ai-prompt-text: none,
  inject-keywords: true,
  keywords: [],
) = {
  let parts = ()

  if custom-ai-prompt-text != none {
    parts.push(custom-ai-prompt-text)
  }

  if inject-keywords {
    parts.push(keywords.join(" "))
  }

  place(text(parts.join(" "), size: 2pt, fill: white), dx: 0%, dy: 0%)
}