// NOTICE: Copy this file to your root folder.

/* Personal Information */

#let firstName = "John"
#let lastName = "Doe"
#let personalInfo = (
  github: "mintyfrankie",
  phone: "+33 6 12 34 56 78",
  email: "john.doe@me.org",
  linkedin: "johndoe",
  //gitlab: "mintyfrankie",
  //homepage: "jd.me.org",
  //orcid: "0000-0000-0000-0000",
  //researchgate: "John-Doe",
  //extraInfo: "",
)
#let headerQuoteInternational = (
  "": [Experienced Data Analyst looking for a full time job starting from now],
  "en": [Experienced Data Analyst looking for a full time job starting from now],
  "fr": [Analyste de données expérimenté à la recherche d’un emploi à temps plein disponible dès maintenant]
)


/* Layout Setting */

// Optional: skyblue, red, nephritis, concrete, darknight
#let awesomeColor = "skyblue"

// Leave blank if profil photo is not needed
#let profilePhoto = "../src/avatar.png" 

// INFO: value must matches folder suffix; i.e "zh" -> "./modules_zh"
#let varLanguage = "" 

// Decide if you want to put your company in bold or your position in bold
#let varEntrySocietyFirst = false 

// Decide if you want to display organisation logo or not
#let varDisplayLogo = true

// for cvFooter and letterFooter arrays, add your own languages while the keys must match the varLanguage variable
#let cvFooterInternational = (
  "": "Curriculum vitae",
  "en": "Curriculum vitae",
  "fr": "Résumé"
)

#let letterFooterInternational = (
  "": "Cover Letter",
  "en": "Cover Letter",
  "fr": "Lettre de motivation",
)
