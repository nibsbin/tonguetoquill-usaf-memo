// lib.typ: A Typst template for Tongue and Quill official memorandums.

// Width of two spaces
#let TWO_SPACES = .5em
#let BLANK_LINE = 1em
#let LINE_SPACING = .5em
#let INDENT_SIZE = 0.5in
#let PAR_COUNTER_PREFIX = "par-counter-"

#let make-par(level, numbering-format, content) = {
  // Indent first line to align with parent paragraph text
  let indent = INDENT_SIZE * level
  let par-counter = counter(PAR_COUNTER_PREFIX+str(level))

  context {
    // The processed number
    let num = par-counter.display(numbering-format)
    par-counter.step()
    
    // Reset the child's counter
    counter(PAR_COUNTER_PREFIX+str(level+1)).update(1)

    // Create the final block with the necessary padding and blank line
    block[
      #v(BLANK_LINE)
      #pad(left: indent)[
        // Create a grid to simulate hanging indent
        #grid(
          columns: (auto, 1fr),
          column-gutter: 0.5em,
          num, content
        )
      ]
    ]
  }
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

#let process-body(content) = {
  // Reset base paragraph counter
  counter("par-counter-0").update(1)
  
  // Function to recursively process content
  show par: it => {
    // Check if this paragraph contains our numbered content by looking for numbered patterns
    let content_str = repr(it.body)
    let is-processed = content_str.contains("grid(") and (
      content_str.contains("1.") or 
      content_str.contains("a.") or 
      content_str.contains("(1)") or 
      content_str.contains("(a)")
    )
    
    if is-processed {
      // This is already a numbered paragraph from our functions, pass it through
      it
    } else {
      // This is a regular paragraph, wrap it with base-par
      base-par(it.body)
    }
  }
  
  // Process the content (this will trigger the show rule)
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
  process-body(body)

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

// Example usage demonstrating the typst-usaf-memo template functionality
#official-memorandum()[

Welcome to the tongue2quill typst template! This template provides automatic formatting for official Air Force memorandums according to AFH 33-337 "The Tongue and Quill" standards.

Key features of this template include automatic:

+ DoD seal placement
+ proper letterhead formatting, standardized spacing and margins, and compliant font usage (Times New Roman 12pt).

*Paragraph Numbering*. The template features automatic paragraph numbering that follows Air Force formatting requirements. Simply write regular paragraphs and they will be numbered sequentially (1., 2., 3., etc.) with proper spacing and indentation.

#sub-par[Wrap paragraphs in `#sub-par[...]` for hierarchical sub-paragraph. Each subpargraph is automatically numbered and indented to comply with AF 33-337.]

#sub-sub-par[`#sub-sub-par[...]` and so on creates deeper levels of sub-paragraphs.]

Key features of the typst-usaf-memo template include automatic DoD seal placement, proper letterhead formatting, standardized spacing and margins, and compliant font usage (Times New Roman 12pt).

#sub-par[The template supports all standard memorandum sections including references, attachments, carbon copy (cc) lists, and distribution lists.]

#sub-par[Customization options allow you to modify letterhead titles, organization information, and signature blocks while maintaining formatting compliance.]

To use this template, simply import it into your Typst document and call the `official-memorandum()` function with your content. Regular paragraphs will be automatically numbered, and you can use `sub-par()`, `sub-sub-par()`, and `sub-sub-sub-par()` functions for hierarchical organization.

The template ensures your documents meet Air Force publication standards while leveraging the power and flexibility of the Typst typesetting system.

]