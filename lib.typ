// lib.typ: A Typst template for Tongue and Quill official memorandums.
#import "indorsement.typ": render_indorsements, Indorsement

//=====Configuration=====
#let TWO_SPACES = 0.5em
#let BLANK_LINE = 1em
#let LINE_SPACING = 0.5em
#let TAB_SIZE = 0.5in
#let PAR_COUNTER_PREFIX = "par-counter-"
#let PAR_NUMBERING_FORMATS = ("1.", "a.", "(1)", "(a)", n => underline(str(n)), n => underline(str(n)))
#let PAR_BLOCK_INDENT = state("BLOCK_INDENT", true)

//==FRONT MATTER
#let auto-grid(rows, column-gutter: .5em) = {
  // Convert 1D array to 2D array for consistent processing
  let normalized_rows = rows
  if rows.len() > 0 and type(rows.at(0)) != array {
    // This is a 1D array, convert each element to a single-element row
    normalized_rows = rows.map(item => (item,))
  }
  
  // Now process as 2D array - columns = max row length
  let n = calc.max(..normalized_rows.map(r => r.len()))

  // build flat list of cells (row-major)
  let cells = ()
  let make-cell = (x) => [#x]   // coerce string/content to a cell

  for row in normalized_rows {
    let k = row.len()
    for i in range(0, n) {
      let v = if i < k { row.at(i) } else { [] }
      cells.push(make-cell(v))
    }
  }

  grid(
    columns: n,
    column-gutter: column-gutter,
    row-gutter: LINE_SPACING,
    ..cells
  )
}

//==CLOSING SECTIONS
// Render closing section with automatic page break handling
#let _render_closing_section(items, label, numbering_style: none, continuation_label: none) = {
  let content = {
    [#label]
    parbreak()
    if numbering_style != none { 
      // Ensure items is always an array for enum
      let item_array = if type(items) == array { items } else { (items,) }
      enum(..item_array, numbering: numbering_style) 
    } else { 
      if type(items) == array {
        items.join("\n")
      } else {
        items
      }
    }
  }
  
  context {
    let available_space = page.height - here().position().y - 1in
    if measure(content).height > available_space {
      if continuation_label != none { 
        continuation_label 
      } else { 
        label + " (listed on next page):" 
      }
      pagebreak()
    }
    content
  }
}

//==BODY PARAGRAPHS
// Get the numbering format for a level
#let _get_numbering_format(level) = {
  if level < PAR_NUMBERING_FORMATS.len() {
    PAR_NUMBERING_FORMATS.at(level)
  } else {
    "1"
  }
}

// Get the indent width for a level
#let _get_paragraph_indent(level) = {
  if level == 0 { return 0pt }
  
  let buffer = ""
  for i in range(0, level) {
    let numbering_format = _get_numbering_format(i)
    buffer += h(TWO_SPACES)
    let _ = counter("paragraph-indent-dummy").update(1)
    buffer += counter("paragraph-indent-dummy").display(numbering_format)
  }
  measure(buffer).width
}

#let _make_par(level, content) = {
  let par_counter = counter(PAR_COUNTER_PREFIX + str(level))
  let numbering_format = _get_numbering_format(level)

  context {
    let num = par_counter.display(numbering_format)
    par_counter.step()
    counter(PAR_COUNTER_PREFIX + str(level + 1)).update(1)
    let indent_amount = _get_paragraph_indent(level)

    block[
      #v(BLANK_LINE)
      #if PAR_BLOCK_INDENT.get() {
        pad(left: indent_amount)[#num#h(TWO_SPACES)#content]
      } else {
        [#h(indent_amount)#num#h(TWO_SPACES)#content]
      }
    ]
  }
}
// Paragraph functions with automatic numbering
#let base-par(content) = _make_par(0, content)
#let sub-par(content) = _make_par(1, content)
#let sub-sub-par(content) = _make_par(2, content)
#let sub-sub-sub-par(content) = _make_par(3, content)
#let sub-sub-sub-sub-par(content) = _make_par(4, content)
#let sub-sub-sub-sub-sub-par(content) = _make_par(5, content)

#let _process_body(content) = {
  counter("par-counter-0").update(1)
  
  show par: it => {
    let content_str = repr(it.body)
    if content_str.contains("grid(") {
      it // Already formatted paragraph
    } else {
      base-par(it.body) // Wrap raw paragraph
    }
  }
  
  content
}

//=====Frontend=====
#let OfficialMemorandum(
  letterhead-title: "DEPARTMENT OF THE AIR FORCE",
  letterhead-caption: "AIR FORCE MATERIEL COMMAND",
  letterhead-seal: "assets/dod_seal.png",
  memo-for: ("ORG/SYMBOL",),
  from-block: (
    "ORG/SYMBOL",
    "Organization",
    "Street Address",
    "City ST 80841-2024"
  ),
  subject: "Format for the Official Memorandum",
  references: (),
  signature-block: (
    "FIRST M. LAST, Rank, USAF",
    "AFIT Masters Student, Carnegie Mellon University",
    "Organization (if not on letterhead)"
  ),
  attachments: (),
  cc: (),
  distribution: (),
  indorsements: (),
  letterhead_font: "Arial",
  body_font: "Times New Roman",
  block_indent: true,
  body
) = {
  // Set document properties
  set document(author: "Typst User", title: subject)
  set page(
    paper: "us-letter",
    margin: (left: 1in, right: 1in, top: 1in, bottom: 1in),
  )
  set text(font: body_font, size: 12pt)
  set par(leading: LINE_SPACING, spacing: LINE_SPACING)
  PAR_BLOCK_INDENT.update(block_indent)

  // Page numbering (starts on page 2)
  context {
    if counter(page).get().first() > 1 {
      place(
        top + right,
        dx: 0in,
        dy: -0.5in,
        text(12pt)[#counter(page).display()]
      )
    }
  }

  // Letterhead
  box(
    width: 100%,
    height: 0.75in,
    fill: none,
    stroke: none,
    [
      #place(
        center + top,
        align(center)[
          #text(12pt, weight: "bold", font: letterhead_font)[#letterhead-title]\
          #text(10.5pt, weight: "bold", font: letterhead_font, fill: luma(24%))[#letterhead-caption]
        ]
      )
      
      #place(
        left + horizon,
        dx: -0.25in,
        dy: -0.125in,
        image(letterhead-seal, width: 1in, height: 2in, fit: "contain")
      )
    ]
  )

  // Date (AFH 33-337: 1.75 inches from top, flush right)
  align(right)[#datetime.today().display("[day] [month repr:long] [year]")]

  // MEMORANDUM FOR block
  v(BLANK_LINE)
  grid(
    columns: (auto, TWO_SPACES, 1fr),
    "MEMORANDUM FOR", "",
    align(left)[
      #if type(memo-for) == array {
        // Use auto-grid which handles both 1D and 2D arrays
        auto-grid(memo-for, column-gutter: TAB_SIZE)
      } else {
        memo-for
      }
    ]
  )

  // FROM block
  v(BLANK_LINE)
  grid(
    columns: (auto, TWO_SPACES, 1fr),
    "FROM:", "",
    align(left)[#from-block.join("\n")]
  )

  // SUBJECT block
  v(BLANK_LINE)
  grid(
    columns: (auto, TWO_SPACES, 1fr),
    "SUBJECT:", "", [#subject]
  )

  // References (optional)
  if references.len() > 0 {
    v(BLANK_LINE)
    grid(
      columns: (auto, TWO_SPACES, 1fr),
      "References:", "", enum(..references, numbering: "(a)")
    )
  }

  // Body content
  set par(justify: true)
  _process_body(body)

  // Signature Block with page break handling
  context {
    let signature_content = {
      v(5em)
      align(left)[
        #pad(left: 4.5in - 1in)[
          #text(hyphenate: false)[
            #for line in signature-block {
              par(hanging-indent: 1em, justify: false)[#line]
            }
          ]
        ]
      ]
    }
    
    let available_space = page.height - here().position().y - 1in
    let signature_height = measure(signature_content).height
    
    if signature_height > available_space {
      pagebreak(weak: true)
    }
    
    signature_content
  }
  // Closing sections
  let has_attachments = attachments.len() > 0
  let has_cc = cc.len() > 0
  let has_distribution = distribution.len() > 0
  
  // Attachments
  if has_attachments {
    v(3 * LINE_SPACING)
    let num = attachments.len()
    let label = if num == 1 { "Attachment:" } else { str(num) + " Attachments:" }
    let continuation = (if num == 1 { "Attachment" } else { str(num) + " Attachments" }) + " (listed on next page):"
    _render_closing_section(attachments, label, numbering_style: "1.", continuation_label: continuation)
  }

  // cc
  if has_cc {
    v(if has_attachments { 2 * LINE_SPACING } else { 3 * LINE_SPACING })
    _render_closing_section(cc, "cc:")
  }

  // Distribution
  if has_distribution {
    v(if has_attachments or has_cc { 2 * LINE_SPACING } else { 3 * LINE_SPACING })
    _render_closing_section(distribution, "DISTRIBUTION:")
  }

  // Indorsements
  if indorsements.len() > 0 {
    render_indorsements(indorsements, body_font: body_font)
  }
  
}

//=====Example=====
#OfficialMemorandum()[

Welcome to the Typst USAF Memo template! This template provides automatic formatting for official Air Force memorandums according to AFH 33-337 "The Tongue and Quill" standards. This comprehensive template eliminates the tedious formatting work that typically consumes valuable time when preparing official correspondence.

The template has been meticulously designed to ensure full compliance with Air Force publishing standards while providing a streamlined user experience. Key features and capabilities include:

#sub-par[*Automatic paragraph numbering and formatting*. Paragraphs are automatically numbered using the proper Air Force hierarchy (1., a., (1), (a)) and spaced with precise line spacing. Writers can focus entirely on content while the template handles all formatting requirements including proper indentation, alignment, and spacing between elements.]

#sub-par[*Hierarchical document structure*. The template supports multi-level paragraph organization essential for complex policy documents and detailed instructions. Each subparagraph level is automatically numbered and properly indented to maintain visual clarity and regulatory compliance.]

#sub-sub-par[Implementation is straightforward: simply wrap content in the appropriate paragraph function such as `sub_par[...]` for first-level subparagraphs, `sub_sub_par[...]` for second-level, and so forth.]

#sub-par[*Smart page break handling*. The template automatically manages page breaks for closing sections (attachments, cc, and distribution lists) according to AFH 33-337 requirements. If a section doesn't fit on the current page, it uses proper continuation formatting with "(listed on next page)" notation, ensuring no orphaned headers or improper splits.]

#sub-par[*Complete document formatting automation*. All letterhead elements, margins, fonts, date formatting, signature block positioning, and closing elements are automatically configured according to AFH 33-337 specifications. This includes proper placement of the Department of Defense seal scaled to fit a 1in × 2in box while preserving aspect ratio.]

#sub-par[*Flexible content management*. The template accommodates various memorandum types including single addressee, multiple addressee, and distribution lists. Reference citations, attachments, courtesy copies, and distribution lists are all properly formatted and positioned with intelligent page break handling.]

#sub-par[*Professional presentation standards*. Typography follows Air Force requirements with 12-point Times New Roman font, proper line spacing, justified text alignment, and consistent spacing between document elements. Page numbering, when required, is automatically positioned 0.5 inches from the top of the page and flush with the right margin.]

Created by #link("https://github.com/snpm")[Nibs].

]