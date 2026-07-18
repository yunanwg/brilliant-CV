/*
A module containing the injection logic for the AI prompt and keywords.
*/

/// Place hidden ATS/LLM-screener text into the document.
///
/// The text renders as 2pt white and is wrapped in `pdf.artifact` (Typst
/// 0.14+) so assistive technology skips it, while plain-text extraction —
/// what ATS pipelines read — still sees it. Note the text remains
/// extractable via copy/paste, and some screeners actively detect hidden
/// text; the template ships with injection disabled by default.
/// Emits nothing when there is nothing to inject.
#let _inject(
  custom-ai-prompt-text: none,
  keywords: (),
) = {
  let parts = ()

  if custom-ai-prompt-text != none {
    parts.push(custom-ai-prompt-text)
  }

  if keywords.len() > 0 {
    parts.push(keywords.join(" "))
  }

  if parts.len() == 0 {
    return
  }

  place(
    pdf.artifact(text(parts.join(" "), size: 2pt, fill: white)),
    dx: 0%,
    dy: 0%,
  )
}
