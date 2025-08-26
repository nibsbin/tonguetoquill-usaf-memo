// lib.typ: A Typst template for Tongue and Quill official memorandums.

#let official-memorandum(
  letterhead-line-1: "DEPARTMENT OF THE AIR FORCE",
  letterhead-line-2: "ORGANIZATION",
  memo-for: [],
  memo-for-alignment: left,
  from-org: "",
  from-street: "",
  from-city-state-zip: "",
  subject: "",
  references: [],
  body,
  signature-name: "",
  signature-rank: "",
  signature-title: "",
  attachments: [],
  cc: [],
  distribution: [],
) = {
  // Set document properties
  set document(author: "Typst User", title: subject)
  set page(
    paper: "us-letter",
    margin: (left: 1in, right: 1in, top: 1in, bottom: 1in),
    numbering: "1",
  )
  set text(font: "Times New Roman", size: 12pt)

  // DoD Seal - floating in top left corner
  place(
    top + left,
    dx: 0in,
    dy: -.25in,
    image("assets/dod_seal.png", width: 1in)
  )

  // Letterhead - AFH 33-337 compliant (centered text only)
  align(center)[
    // AFH 33-337: First line flush with top margin, 12pt Times New Roman
    #text(12pt, weight: "bold", font: "Times New Roman")[#letterhead-line-1]
    #v(3pt, weak: true)
    // AFH 33-337: Second line 3pt below first, 10.5pt Times New Roman
    #text(10.5pt, weight: "bold", font: "Times New Roman")[#letterhead-line-2]
  ]

  // Date - AFH 33-337: 1.75 inches from top of page, flush right
  v(1.75in - 1in - 12pt - 3pt - 10.5pt, weak: true)
  align(right)[#datetime.today().display("[day] [month repr:long] [year]")]

  // MEMORANDUM FOR - AFH 33-337 compliant spacing
  v(2em, weak: true)
  grid(
    columns: (auto, 2em, 1fr),
    "MEMORANDUM FOR", "", // Two spaces between MEMORANDUM FOR and recipient
    align(memo-for-alignment)[#memo-for]
  )

  // FROM - AFH 33-337 compliant spacing
  v(2em, weak: true)
  "FROM:"
  h(2em) // Two spaces between colon and content
  block[
    #from-org \
    #from-street \
    #from-city-state-zip
  ]

  // SUBJECT - AFH 33-337 compliant spacing
  v(2em, weak: true)
  "SUBJECT:"
  h(2em) // Two spaces between colon and subject
  block[#subject]


  // References
  if references != [] {
    v(2em, weak: true)
    "References:"
    v(1em, weak: true)
    references
  }


  // Body
  v(2em, weak: true)
  body

  // Signature Block
  v(5em, weak: true)
  align(right)[
    #signature-name, #signature-rank \
    #signature-title
  ]

  // Attachments
  if attachments != [] {
    v(3em, weak: true)
    "Attachment:"
    v(1em, weak: true)
    attachments
  }

  // cc
  if cc != [] {
    v(2em, weak: true)
    "cc:"
    v(1em, weak: true)
    cc
  }

  // Distribution
  if distribution != [] {
    v(2em, weak: true)
    "DISTRIBUTION:"
    v(1em, weak: true)
    distribution
  }
}
