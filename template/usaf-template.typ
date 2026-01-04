#import "@preview/tonguetoquill-usaf-memo:1.0.0": backmatter, frontmatter, indorsement, mainmatter

#show: frontmatter.with(
  letterhead_title: "DEPARTMENT OF THE AIR FORCE",
  letterhead_caption: "123RD EXAMPLE SQUADRON",
  letterhead_seal: image("assets/dow_seal.png"),
  subject: "Format for the Official Memorandum",
  memo_for: (
    "123 ES/CC",
    "123 ES/DO",
    "123 ES/CSS",
    "456 ES/CC",
    "456 ES/DO",
    "456 ES/CSS",
  ),
  memo_from: (
    "ORG/SYMBOL",
    "Organization",
    "Street Address",
    "City ST 12345-6789",
  ),
  references: (
    "AFM 33-326, 31 July 2019, Preparing Official Communications",
    "DoDM 5110.04-M-V2, 16 June 2020, Manual for Written Material: Examples and Reference Material",
  ),
)

#mainmatter[
  p1

  - c1.5

  - c2
    - c3
    - c4

  p5
]

#backmatter(
  signature_block: (
    "FIRST M. LAST, Rank, USAF",
    "Duty Title",
  ),
  attachments: (
    "Attachment description, date",
    "Additional attachment description, date",
  ),
  cc: (
    "Rank and name, ORG/SYMBOL, or both"
  ),
  distribution: (
    "ORG/SYMBOL or Organization Name"
  ),
)
