// main.typ: Example usage of the Tongue and Quill official memorandum template.

#import "lib.typ": official-memorandum

#show: doc => official-memorandum(
  letterhead-line-1: "DEPARTMENT OF THE AIR FORCE",
  letterhead-line-2: "AIR FORCE MATERIEL COMMAND",
  memo-for: [
    "123 ES/CC", "123 ES/DO", "123 ES/CSS",
    "456 ES/CC", "456 ES/DO", "456 ES/CSS",
  ],
  from-org: "ORG/SYMBOL",
  from-street: "Street Address",
  from-city-state-zip: "City ST 12345-6789",
  subject: "Format for the Official Memorandum",
  references: [
    "AFM 33-326, 31 July 2019, Preparing Official Communications",
    "DoDM 5110.04-M-V2, 16 June 2020, Manual for Written Material: Examples and Reference Material",
  ],
  signature-name: "FIRST M. LAST",
  signature-rank: "Rank, USAF",
  signature-title: "Duty Title",
  attachments: [
    "Attachment description, date",
  ],
  cc: [
    "Rank and name, ORG/SYMBOL, or both",
  ],
  distribution: [
    "ORG/SYMBOL or Organization Name",
  ],
)[
  Use only approved organizational letterhead for all correspondence. This applies to all letterhead, both pre-printed and computer generated. Reference (a) details for the format and style of official letterhead such as centering the first line of the header 5/8ths of an inch from the top of the page in 12 point Copperplate Gothic Bold font. The second header line is centered 3 points below the first line in 10.5 point Copperplate Gothic Bold font.

  Place "MEMORANDUM FOR" on the second line below the date. Leave two spaces between "MEMORANDUM FOR" and the recipient's office symbol. If there are multiple recipients, two or three office symbols may be placed on each line aligned under the entries on the first line. If there are numerous recipients, type "DISTRIBUTION" after "MEMORANDUM FOR" and use a "DISTRIBUTION" element below the signature block.

  Place "FROM:" on the second line below the "MEMORANDUM FOR" line. Leave two spaces between the colon in "FROM:" and the originator's office symbol. The "FROM:" element contains the full mailing address of the originator's office unless the mailing address is in the header or if all the recipients are located in the same installation as the originator.

  Place "SUBJECT:" in uppercase letters on the second line below the last line of the FROM element. Leave two spaces between the colon in "SUBJECT:" and the subject. Capitalize the first letter of each word except articles, prepositions, and conjunctions (this is sometimes referred to as "title case"). Be clear and concise. If the subject is long, try to revise and shorten the subject; if shortening is not feasible, align the second line under the first word of the subject.
]
