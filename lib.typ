// lib.typ: A Typst template for Tongue and Quill official memorandums.

//=====Backend=====
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

//=====Frontend=====
#let official-memorandum(
  letterhead-title: "DEPARTMENT OF THE AIR FORCE",
  letterhead-caption: "ORGANIZATION",
  memo-for: "ORG/SYMBOL",
  from-block: [
    ORG/SYMBOL\
    Organization\
    Street Address\
    City ST 80841-2024
  ],
  subject: "Format for the Official Memorandum",
  references: (
    "AFH 33-337, 27 May 2015, The Tongue and Quill",
    "AFI 33-360, 18 May 2006, Publications and Forms Management"
  ),
  body,
  signature-block: (
    "FIRST M. LAST, Rank, USAF",
    "AFIT Masters Student, Carnegie Mellon University",
    "Organization (if not on letterhead)"
  ),
  attachments: (
    "SAF/CIO A6 Memo, 12 Oct 2011, Air Force Guidance Memorandum",
    "AFI 33-360, 18 May 2006, Publications and Forms Management"
  ),
  
  cc: [
    HQ AETC/A1\
    12 FS/DO (Capt Thomas Moore)
  ],
  distribution: [
    HQ USAF/A1\
    HQ PACAF/A1\
    HQ ACC/A1
    ],
) = {
  // Set document properties
  set document(author: "Typst User", title: subject)
  set page(
    paper: "us-letter",
    margin: (left: 1in, right: 1in, top: 1in, bottom: 1in),
  )
  set text(font: "Times New Roman", size: 12pt)
  set par(leading: LINE_SPACING, spacing: LINE_SPACING)

  // AFH 33-337: Page numbering - floating, 0.5-inch from top, flush right
  // First page never numbered, start with page 2
  context {
    if counter(page).get().first() > 1 {
      place(
        top + right,
        dx: 0in,  // Flush with right margin (no offset)
        dy: -0.5in,
        text(12pt)[#counter(page).display()]
      )
    }
  }

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

  // Signature Block - AFH 33-337: 4.5 inches from left edge or 3 spaces right of center
  // AFH 33-337: Start on fifth line below last line of text
  v(5em) 
  align(left)[
    //4.5in from left edge minus 1in margin
    #pad(left: 4.5in-1in)[
      #text(hyphenate: false)[
      #for line in signature-block {
        par(hanging-indent: 1em,justify: false)[#line]
      }]
    ]
  ]
  
  // Attachments - AFH 33-337: at left margin, third line below signature element
  if attachments != [] {
    v(3 * LINE_SPACING) // Third line below signature = 3 line spaces
    let num_attachments = attachments.len()
    if num_attachments == 1 { "Attachment:" } else { str(num_attachments) + " Attachments:" }
    parbreak() // No space; just a line break
    enum(..attachments, numbering: "1.")
  }

  // cc - AFH 33-337: flush left, second line below attachment OR third line below signature
  if cc != [] {
    if attachments != [] {
      v(2 * LINE_SPACING) // Second line below attachment element
    } else {
      v(3 * LINE_SPACING) // Third line below signature element if no attachments
    }
    [cc:]
    parbreak()
    cc
  }

  // Distribution - AFH 33-337: flush left, second line below attachment/cc OR third line below signature
  if distribution != [] {
    if cc != [] {
      v(2 * LINE_SPACING) // Second line below cc element
    } else if attachments != [] {
      v(2 * LINE_SPACING) // Second line below attachment element
    } else {
      v(3 * LINE_SPACING) // Third line below signature element if no attachments or cc
    }
    [DISTRIBUTION:]
    parbreak()
    distribution
  }
}

//=====Example=====
#official-memorandum()[

Welcome to the tongue2quill Typst template! This template provides automatic formatting for official Air Force memorandums according to AFH 33-337 "The Tongue and Quill" standards. This comprehensive template eliminates the tedious formatting work that typically consumes valuable time when preparing official correspondence.

The template has been meticulously designed to ensure full compliance with Air Force publishing standards while providing a streamlined user experience. Key features and capabilities include:

#sub-par[*Automatic paragraph numbering and formatting*. Paragraphs are automatically numbered using the proper Air Force hierarchy (1., a., (1), (a)) and spaced with precise line spacing. Writers can focus entirely on content while the template handles all formatting requirements including proper indentation, alignment, and spacing between elements.]

#sub-par[*Hierarchical document structure*. The template supports multi-level paragraph organization essential for complex policy documents and detailed instructions. Each subparagraph level is automatically numbered and properly indented to maintain visual clarity and regulatory compliance.]

#sub-sub-par[Implementation is straightforward: simply wrap content in the appropriate paragraph function such as `sub-par[...]` for first-level subparagraphs, `sub-sub-par[...]` for second-level, and so forth.]

#sub-par[*Complete document formatting automation*. All letterhead elements, margins, fonts, date formatting, signature block positioning, and closing elements are automatically configured according to AFH 33-337 specifications. This includes proper placement of the Department of Defense seal, organization letterhead, and precise positioning of all document elements.]

#sub-par[*Flexible content management*. The template accommodates various memorandum types including single addressee, multiple addressee, and distribution lists. Reference citations, attachments, courtesy copies, and distribution lists are all properly formatted and positioned.]

#sub-par[*Professional presentation standards*. Typography follows Air Force requirements with 12-point Times New Roman font, proper line spacing, justified text alignment, and consistent spacing between document elements. Page numbering, when required, is automatically positioned 0.5 inches from the top of the page and flush with the right margin.]

Created by #link("https://github.com/snpm")[Nibs].

]