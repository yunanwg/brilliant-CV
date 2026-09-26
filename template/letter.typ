// Required fonts: Roboto, Source Sans 3 (or Source Sans Pro), and the
// Font Awesome 7 Free desktop OTFs (Regular, Solid, Brands) — get them from
// https://fonts.google.com/specimen/Roboto,
// https://fonts.google.com/specimen/Source+Sans+3, and
// https://fontawesome.com/download. Install locally for desktop Typst.
// On typst.app, the web app does not bundle Font Awesome — upload the three
// .otf files to your project instead, or contact icons render as boxes.
// See https://yunanwg.github.io/brilliant-CV/ (Troubleshooting) for details.

// Imports
#import "@preview/brilliant-cv:4.1.1": letter

// Each profile lives in its own folder with a self-contained metadata.toml.
// Switch profile at compile time:
//   typst compile letter.typ --input profile=fr
#let profile = sys.inputs.at("profile", default: "en")
#let metadata = toml("profile_" + profile + "/metadata.toml")
// The name you sign with: display_name when the profile sets one.
#let signer = metadata.personal.at(
  "display_name",
  default: metadata.personal.first_name + " " + metadata.personal.last_name,
)


#show: letter.with(
  metadata,
  // sender-address defaults to [personal] address in the profile's metadata.toml.
  // Override it here only for a one-off letter:
  // sender-address: "123 Main St" + "\n" + "San Francisco, CA 94102",
  recipient-name: "Acme Analytics",
  // Supports multiline addresses:
  recipient-address: "456 Market St" + "\n" + "New York, NY 10001",
  // date defaults to today; pass a string to override:
  date: datetime.today().display(),
  subject: "Application for Head of Data Science",
  // address-style: "normal",  // use "normal" to disable smallcaps on addresses
)

Dear Hiring Manager,

I am excited to submit my application for the Head of Data Science position at Acme Analytics. With over 8 years of experience in data analysis and a demonstrated track record of success, I am confident in my ability to make a valuable contribution to your team.

In my current role as Director of Data Science at XYZ Corporation, I have gained extensive experience in data mining, quantitative analysis, and data visualization. Through my work, I have developed a deep understanding of statistical concepts and have become adept at using tools such as SQL, Python, and R to extract insights from complex datasets. I have also gained valuable experience in presenting complex data in a visually appealing and easily accessible manner to stakeholders across all levels of an organization.

I believe that my experience in data analysis makes me an ideal candidate for the Head of Data Science position at Acme Analytics. I am particularly excited about the opportunity to apply my skills to support your organization's mission and drive impactful insights. Your focus on driving innovative solutions to complex problems aligns closely with my own passion for using data analysis to drive positive change in organizations.

Furthermore, I have extensive experience in developing and implementing data-driven solutions that improve business operations. For example, as a volunteer analyst I built predictive models that increased donation efficiency by 25%. I have also built Tableau dashboards that give stakeholders a clear view of business performance, so that they can make more informed decisions.

As a highly motivated and detail-oriented individual, I am confident that I would thrive in the fast-paced and dynamic environment at Acme Analytics. I am excited about the opportunity to work with a talented team of professionals and to continue developing my skills in data analysis.

Thank you for considering my application. I look forward to the opportunity to discuss my qualifications further.

// Keep the closing, the signature, and your name together: an unbreakable
// block moves to the next page as one unit. Scanned signatures are personal
// and sensitive — avoid committing real ones to public git repos.
#block(breakable: false)[
  Sincerely,

  #image("assets/signature.png", width: 25%, alt: "Signature")

  #signer
]
