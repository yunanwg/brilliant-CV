/*
A module containing the injection logic for the AI prompt and keywords.
*/


#let inject(
  if_inject_ai_prompt: true,
  if_inject_keywords: true,
  keywords_list: [],
  injected_ai_prompt: ""
) = {
  let prompt = ""
  if if_inject_ai_prompt {
    prompt = prompt + injected_ai_prompt
  }
  if if_inject_keywords {
    prompt = prompt + " " + keywords_list.join(" ")
  }

  place(text(prompt, size: 2pt, fill: white), dx: 0%, dy: 0%)
}
