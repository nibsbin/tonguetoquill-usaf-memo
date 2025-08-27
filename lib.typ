// lib.typ: A Typst template for Tongue and Quill official memorandums.

//=====Backend=====
#let TWO_SPACES = .5em
#let BLANK_LINE = 1em
#let LINE_SPACING = .5em
#let INDENT_SIZE = 0.5in
#let PAR_COUNTER_PREFIX = "par-counter-"

// Render closing section with automatic page break handling
#let render-closing-section(items, label, numbering-style: none, continuation-label: none) = {
  let content = {
    [#label]
    parbreak()
    if numbering-style != none { enum(..items, numbering: numbering-style) } else { items.join("\n") }
  }
  
  context {
    let available_space = page.height - here().position().y - 1in
    if measure(content).height > available_space {
      // Use continuation format
      if continuation-label != none { continuation-label } else { label + " (listed on next page):" }
      pagebreak()
    }
    content
  }
}

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

// Level 4 subpagraph: 4 indents, itemizes with underlined 1
#let sub-sub-sub-sub-par(content) = {
  make-par(4, underline("1"), content)
}

// Level 5 subpagraph: 5 indents, itemizes with underlined a
#let sub-sub-sub-sub-sub-par(content) = {
  make-par(5, underline("a"), content)
}

#let process-body(content) = {
  // Reset base paragraph counter
  counter("par-counter-0").update(1)
  
  // Function to recursively process content
  show par: it => {
    // Check if this paragraph is aligned/formatted
    let content_str = repr(it.body)
    let is-processed = content_str.contains("grid(")
    
    if is-processed {
      // This is already a formatted paragraph, pass it through
      it
    } else {
      // This is a raw paragraph, wrap it with base-par
      base-par(it.body)
    }
  }
  
  // Process the content (this will trigger the show rule)
  content
}

//=====Frontend=====
#let usaf-memo(
  letterhead-title: "DEPARTMENT OF THE AIR FORCE",
  letterhead-caption: "AIR FORCE MATERIEL COMMAND",
  letterhead-seal: "assets/dod_seal.png",
  memo-for: "ORG/SYMBOL",
  from-block: (
    "ORG/SYMBOL",
    "Organization",
    "Street Address",
    "City ST 80841-2024"
  ),
  subject: "Format for the Official Memorandum",
  references: (
    "AFH 33-337, 27 May 2015, The Tongue and Quill",
    "AFI 33-360, 18 May 2006, Publications and Forms Management"
  ),
  signature-block: (
    "FIRST M. LAST, Rank, USAF",
    "AFIT Masters Student, Carnegie Mellon University",
    "Organization (if not on letterhead)"
  ),
  attachments: (
    "SAF/CIO A6 Memo, 12 Oct 2011, Air Force Guidance Memorandum",
    "AFI 33-360, 18 May 2006, Publications and Forms Management"
  ),
  
  cc: (
    "HQ AETC/A1",
    "12 FS/DO (Capt Thomas Moore)"
  ),
  distribution: (
    "HQ USAF/A1",
    "HQ PACAF/A1",
    "HQ ACC/A1"
    ),
  body
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

  // Letterhead
  box(
    width: 100%, // Full content width
    height: 0.75in, // Reserved letterhead height
    fill: none,
    stroke: none,
    [
      // Center: Title and Caption - main content positioned at center
      #place(
        center + horizon,
        [
          #align(center)[
            #text(12pt, weight: "bold", font: "Times New Roman")[#letterhead-title]\
            #text(10.5pt, weight: "bold", font: "Times New Roman", fill: luma(24%))[#letterhead-caption]
          ]
        ]
      )
      
      // Left: Seal - positioned independently on the left
      #place(
        left + horizon,
        dx: -.25in,
        dy: -.125in,
        [#image(letterhead-seal, width: 1in, height: 2in, fit: "contain")]
      )
    ]
  )

  // Date - AFH 33-337: 1.75 inches from top of page, flush right
  align(right)[#datetime.today().display("[day] [month repr:long] [year]")]

  // MEMORANDUM FOR block
  v(BLANK_LINE)
  grid(
    columns: (auto, TWO_SPACES, 1fr),
    "MEMORANDUM FOR", "", // Two spaces between MEMORANDUM FOR and rWecipient
    align(left)[#memo-for]
  )


  // FROM - AFH 33-337: on the second line below the last line of MEMORANDUM FOR
  v(BLANK_LINE)
  grid(
    columns: (auto, TWO_SPACES, 1fr),
    text(12pt)[FROM:], "", // Two spaces between FROM: and content
    align(left)[
      #from-block.join("\n")
    ]
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
    v(3 * LINE_SPACING)
    let num = attachments.len()
    let label = (if num == 1 { "Attachment:" } else { str(num) + " Attachments:" })
    let continuation = (if num == 1 { "Attachment" } else { str(num) + " Attachments" }) + " (listed on next page):"
    
    render-closing-section(attachments, label, numbering-style: "1.", continuation-label: continuation)
  }

  // Helper function to add proper spacing for closing sections
  let add-closing-spacing(has_attachments, has_cc) = {
    if has_attachments or has_cc {
      v(2 * LINE_SPACING) // Second line below previous element
    } else {
      v(3 * LINE_SPACING) // Third line below signature if first element
    }
  }

  // cc - AFH 33-337: flush left, second line below attachment OR third line below signature
  if cc != [] {
    add-closing-spacing(attachments != [], false)
    render-closing-section(cc, "cc:")
  }

  // Distribution - AFH 33-337: flush left, second line below attachment/cc OR third line below signature
  if distribution != [] {
    add-closing-spacing(attachments != [], cc != [])
    render-closing-section(distribution, "DISTRIBUTION:")
  }
}

//=====Example=====
#usaf-memo()[

Welcome to the Typst USAF Memo template! This template provides automatic formatting for official Air Force memorandums according to AFH 33-337 "The Tongue and Quill" standards. This comprehensive template eliminates the tedious formatting work that typically consumes valuable time when preparing official correspondence.

The template has been meticulously designed to ensure full compliance with Air Force publishing standards while providing a streamlined user experience. Key features and capabilities include:

#sub-par[*Automatic paragraph numbering and formatting*. Paragraphs are automatically numbered using the proper Air Force hierarchy (1., a., (1), (a)) and spaced with precise line spacing. Writers can focus entirely on content while the template handles all formatting requirements including proper indentation, alignment, and spacing between elements.]

#sub-par[*Hierarchical document structure*. The template supports multi-level paragraph organization essential for complex policy documents and detailed instructions. Each subparagraph level is automatically numbered and properly indented to maintain visual clarity and regulatory compliance.]

#sub-sub-par[Implementation is straightforward: simply wrap content in the appropriate paragraph function such as `sub-par[...]` for first-level subparagraphs, `sub-sub-par[...]` for second-level, and so forth.]

#sub-par[*Smart page break handling*. The template automatically manages page breaks for closing sections (attachments, cc, and distribution lists) according to AFH 33-337 requirements. If a section doesn't fit on the current page, it uses proper continuation formatting with "(listed on next page)" notation, ensuring no orphaned headers or improper splits.]

#sub-par[*Complete document formatting automation*. All letterhead elements, margins, fonts, date formatting, signature block positioning, and closing elements are automatically configured according to AFH 33-337 specifications. This includes proper placement of the Department of Defense seal scaled to fit a 1in × 2in box while preserving aspect ratio.]

#sub-par[*Flexible content management*. The template accommodates various memorandum types including single addressee, multiple addressee, and distribution lists. Reference citations, attachments, courtesy copies, and distribution lists are all properly formatted and positioned with intelligent page break handling.]

#sub-par[*Professional presentation standards*. Typography follows Air Force requirements with 12-point Times New Roman font, proper line spacing, justified text alignment, and consistent spacing between document elements. Page numbering, when required, is automatically positioned 0.5 inches from the top of the page and flush with the right margin.]

Created by #link("https://github.com/snpm")[Nibs].

]