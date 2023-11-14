// NOTICE: Copy this file to your root folder.

/* Personal Information */
#let firstName = "John"

#let lastName = "Doe"

#let personalInfo = (
  github: "mintyfrankie",
  phone: "+33 6 12 34 56 78",
  email: "john.doe@me.org",
  linkedin: "johndoe",
  //custom-1: (icon: "", text: "example", link: "https://example.com"),
  //gitlab: "mintyfrankie",
  //homepage: "jd.me.org",
  //orcid: "0000-0000-0000-0000",
  //researchgate: "John-Doe",
  //extraInfo: "",
)


/* Language-specific */
// Add your own languages while the keys must match the varLanguage variable
#let headerQuoteInternational = (
  "": [Experienced Data Analyst looking for a full time job starting from now],
  "en": [Experienced Data Analyst looking for a full time job starting from now],
  "fr": [Analyste de données expérimenté à la recherche d'un emploi à temps plein disponible dès maintenant],
  "zh": [具有丰富经验的数据分析师，随时可入职]
)

#let cvFooterInternational = (
  "": "Curriculum vitae",
  "en": "Curriculum vitae",
  "fr": "Résumé",
  "zh": "简历"
)

#let letterFooterInternational = (
  "": "Cover Letter",
  "en": "Cover Letter",
  "fr": "Lettre de motivation",
  "zh": "申请信"
)

#let nonLatinOverwriteInfo = (
  "customFont": "Heiti SC",
  "firstName": "王道尔",
  "lastName": "",
  // submit an issue if you think other variables should be in this array
)

/* Layout Setting */
#let awesomeColor = "skyblue" // Optional: skyblue, red, nephritis, concrete, darknight

#let profilePhoto = "../src/avatar.png" // Leave blank if profil photo is not needed

#let varLanguage = "" // INFO: value must matches folder suffix; i.e "zh" -> "./modules_zh"

#let varEntrySocietyFirst = false // Decide if you want to put your company in bold or your position in bold

#let varDisplayLogo = true // Decide if you want to display organisation logo or not
