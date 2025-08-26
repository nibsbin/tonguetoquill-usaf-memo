// lib.typ: A Typst template for Tongue and Quill official memorandums.

// Width of two spaces
#let TWO_SPACES = .5em
#let BLANK_LINE = 1em
#let LINE_SPACING = .5em
#let INDENT_SIZE = 0.5in
#let PAR_COUNTER_PREFIX = "par-counter-"

// Base function for creating subparagraphs with different numbering schemes
#let make-par(level, numbering-format, content) = {
  let indent = INDENT_SIZE * level
  let par-counter = counter(PAR_COUNTER_PREFIX+str(level))
  
  block()[
    #context {
      par-counter.step()
      let num = par-counter.display(numbering-format)
      // AFH 33-337: Indent first line to align number with parent paragraph text,
      // subsequent lines wrap to left margin (no indent)
      v(BLANK_LINE)
      pad(left: indent)[
        #par(hanging-indent: -indent)[#num #content]
      ]
    }
  ]

  // Reset child counter
  counter(PAR_COUNTER_PREFIX+str(level+1)).update(1)
}

// Base paragraph function: 0 indent, itemizes with numbers
#let base-par(content) = {
  make-par(0, "1.", content)
}

// Level 1 subparagraph: 1 indent, itemizes with a.
#let sub-par(content) = {
  make-par(1, "a.", content)
}

// Level 2 subparagraph: 2 indents, itemizes with (1)
#let sub-sub-par(content) = {
  make-par(2, "(1)", content)
}

// Level 3 subparagraph: 3 indents, itemizes with (a)
#let sub-sub-sub-par(content) = {
  make-par(3, "(a)", content)
}

// Function to process raw text into AFH 33-337 compliant body formatting
#let process-afh-body(content) = {
  //reset base paragraph counter
  counter("par-counter-0").update(1)
  
  // Simply return the content - users will use base-par() and sub-par() functions
  content
}

#let official-memorandum(
  letterhead-title: "DEPARTMENT OF THE AIR FORCE",
  letterhead-caption: "ORGANIZATION",
  memo-for: "ORG/SYMBOL",
  from-block: [
    ORG/SYMBOL\
    Organization\
    Street Address\
    City ST 12345-6789
  ],
  subject: "Format for the Official Memorandum",
  references: (
    "AFH 33-337, 27 May 2015, The Tongue and Quill",
    "AFI 33-360, 18 May 2006, Publications and Forms Management" 
  ),
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
  set par(leading: LINE_SPACING, spacing: LINE_SPACING)
  
  // DoD Seal - floating in top left corner
  place(
    top + left,
    dx: -.24in,
    dy: -.24in,
    image("assets/dod_seal.png", width: 1in)
  )

  // Letterhead - positioned absolutely to not affect flow
  place(
    top + center,
    align(center)[
      #text(12pt, weight: "bold", font: "Times New Roman")[#letterhead-title]\
      #text(10.5pt, weight: "bold", font: "Times New Roman", fill: luma(24%))[#letterhead-caption]
    ]
  )

  // Date - AFH 33-337: 1.75 inches from top of page, flush right
  // Create invisible placeholder content to reserve space for letterhead
  block(height: 0.75in, width: 100%)[#hide[]]
  align(right)[#datetime.today().display("[day] [month repr:long] [year]")]

  // MEMORANDUM FOR block
  v(BLANK_LINE)
  grid(
    columns: (auto, TWO_SPACES, 1fr),
    "MEMORANDUM FOR", "", // Two spaces between MEMORANDUM FOR and recipient
    align(left)[#memo-for]
  )


  // FROM - AFH 33-337: on the second line below the last line of MEMORANDUM FOR
  v(BLANK_LINE)
  grid(
    columns: (auto, TWO_SPACES, 1fr),
    text(12pt)[FROM:], "", // Two spaces between FROM: and content
    align(left)[#from-block]
  )

  // SUBJECT - AFH 33-337: on the second line below the last line of FROM
  v(BLANK_LINE)
  grid(
    columns: (auto, TWO_SPACES, 1fr),
    "SUBJECT:", "", [#subject]
  )


  // References - AFH 33-337: on the second line below the last line of SUBJECT
  if references != [] {
    v(BLANK_LINE)
    grid(
      columns: (auto, TWO_SPACES, 1fr),
      "References:", "", enum(..references, numbering: "(a)")
    )
  }


  // Body - Apply proper formatting per AFH 33-337 with automatic paragraph numbering
  // AFH 33-337: Begin text on the second line below the subject or references
  v(BLANK_LINE)
  // AFH 33-337: Justify text for professional appearance
  set par(justify: true)
  process-afh-body(body)

  // Signature Block
  v(5em)
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

#official-memorandum()[
#base-par()[Use only approved organizational letterhead for all correspondence.  This applies to all letterhead, both pre-printed and computer generated.  Reference (a) details for the format and style of official letterhead such as centering the first line of the header 5/8ths of an inch from the top of the page in 12 point Copperplate Gothic Bold font (Letterhead Line 1 style of this template).  The second header line is centered 3 points below the first line in 10.5 point Copperplate Gothic Bold font (Letterhead Line 2 style of this template).]
#base-par()[Note that this template provides proper formatting for various elements via Word Styles.  The recipient line uses the “MEMO FOR” style, the body of the memorandum uses the “Body” style, the signature block uses the “Signature Block” style, and so on.  The “Normal” style is left available for edge cases not covered by this template, but should be used sparingly, if at all.]
#base-par()[Place “MEMORANDUM FOR” on the second line below the date.  Leave two spaces between “MEMORANDUM FOR” and the recipient’s office symbol.  If there are multiple recipients, two or three office symbols may be placed on each line aligned under the entries on the first line.  If there are numerous recipients, type “DISTRIBUTION” after “MEMORANDUM FOR” and use a “DISTRIBUTION” element below the signature block.]
#base-par()[Place “FROM:” on the second line below the “MEMORANDUM FOR” line.  Leave two spaces between the colon in “FROM:” and the originator’s office symbol.  The “FROM:” element contains the full mailing address of the originator’s office unless the mailing address is in the header or if all the recipients are located in the same installation as the originator.]
#base-par()[Place “SUBJECT:” in uppercase letters on the second line below the last line of the FROM element.  Leave two spaces between the colon in “SUBJECT:” and the subject.  Capitalize the first letter of each word except articles, prepositions, and conjunctions (this is sometimes referred to as “title case”).  Be clear and concise.  If the subject is long, try to revise and shorten the subject; if shortening is not feasible, align the second line under the first word of the subject.]
#base-par()[Body text begins on the second line below the last line in the subject element and is flush with the left margin.  If the Reference element is used, then the body text begins on the second line below the last line on the Reference element.]
#sub-par()[When a paragraph is split between pages, there must be at least two lines from the paragraph on both pages.  This template should automatically handle this formatting, but in the case of widowed sentences you can use a manual page break.  Similarly, avoid single-sentence paragraphs by revising or reorganizing the content.]
#sub-par()[Number or letter each body text paragraph and subparagraph according to the format for subdividing paragraphs in official memorandums presented in the Tongue and Quill. This subdivision format is provided in this template in the “Body” style.  When a memorandum is subdivided, the number of levels used should be relative to the length of the memorandum.  Shorter products typically use three or fewer levels.  Longer products may use more levels, but only the number of levels needed.]
#base-par()[Follow the spacing guidance for between the text, signature block, attachment element, courtesy copy element, and distribution lists, if used, carefully.  The signature block starts on the fifth line below the body text – this spacing is handled automatically by the Signature Block style.  Never separate the text from the signature block: the signature page must include body text above the signature block.  Also, the first element below the signature block begins on the third line below the last line of the duty title; this applies to attachments, courtesy copies, and distribution lists, whichever is used first.]
#base-par()[Elements of the Official Memorandum can be inserted as templated parts in MS Word.  Select the “Insert” menu, “Quick Parts”, and then select the desired element.  Follow the formatting instructions provided with the element template.]
#base-par()[To add classification banner markings (including FOUO markings), click on the header or footer, and in the “Header & Footer Tools” tab, select the Header / Footer dropdown menus on the left side. Use the pre-generated headers and footers – note that the first page is different from the second page onward, and so the second page header and footer must be applied separately. ]
#base-par()[The example of this memorandum applies to many official memorandums that Airmen may be tasked to prepare; however, there are additional elements for special uses of the official memorandum.  Refer to the Tongue and Quill discussion on the official memorandum for more details, or consult published guidance applicable to your duties.]

]
