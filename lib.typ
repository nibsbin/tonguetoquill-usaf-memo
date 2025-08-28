// lib.typ: A Typst template for Tongue and Quill official memorandums.
#import "utils.typ": *

//=====User-Facing Functions=====

// Paragraph functions with automatic numbering
#let base-par(content) = _make_par(0, content)
#let sub-par(content) = _make_par(1, content)
#let sub-sub-par(content) = _make_par(2, content)
#let sub-sub-sub-par(content) = _make_par(3, content)
#let sub-sub-sub-sub-par(content) = _make_par(4, content)
#let sub-sub-sub-sub-sub-par(content) = _make_par(5, content)

//=====Data Structures=====

// Indorsement data structure
#let Indorsement(
  office_symbol: "ORG/SYMBOL",
  memo_for: "ORG/SYMBOL",
  signature_block: (
    "FIRST M. LAST, Rank, USAF",
    "Duty Title",
    "Organization (if not on letterhead)"
  ),
  attachments: (),
  cc: (),
  body: none,
  leading_pagebreak: false,
  separate_page: false,
  original_office: none,
  original_date: none,
  original_subject: none
) = {
  let data = (
    office_symbol: office_symbol,
    memo_for: memo_for,
    signature_block: signature_block,
    attachments: attachments,
    cc: cc,
    body: body,
    leading_pagebreak: leading_pagebreak,
    separate_page: separate_page,
    original_office: original_office,
    original_date: original_date,
    original_subject: original_subject
  )
  
  data.render = (body_font: "Times New Roman") => {
    context {
      set text(font: body_font, size: 12pt)
      set par(leading: LINE_SPACING, spacing: .5em, justify: true)
      
      // Get current indorsement number and increment counter
      let ind_num = INDORSEMENT_COUNTER.get().first() + 1
      INDORSEMENT_COUNTER.step()
      let ind_label = _format_indorsement_number(ind_num)
      
      // Add page break if requested
      if data.leading_pagebreak {
        pagebreak()
      }
      
      // Check if this is a separate-page indorsement
      if data.separate_page and data.original_office != none {
        // AFH 33-337: Separate-page indorsement format
        [#ind_label to #data.original_office, #data.original_date, #data.original_subject]
        
        v(BLANK_LINE)
        [#data.office_symbol#h(TWO_SPACES)#datetime.today().display("[day] [month repr:short] [year]")]
        
        v(BLANK_LINE)
        grid(
          columns: (auto, TWO_SPACES, 1fr),
          "MEMORANDUM FOR", "", data.memo_for
        )
      } else {
        // AFH 33-337: Begin indorsement on second line below last element
        v(BLANK_LINE)
        
        // Indorsement header: "1st Ind, ORG/SYMBOL"
        [#ind_label, #data.office_symbol]
        
        // AFH 33-337: MEMORANDUM FOR on next line
        v(BLANK_LINE)
        grid(
          columns: (auto, TWO_SPACES, 1fr),
          "MEMORANDUM FOR", "", data.memo_for
        )
      }
      
      // Body content (if provided)
      if data.body != none {
        v(BLANK_LINE)
        _process_body(data.body, base-par)
      }
      
      // Signature Block - AFH 33-337: 4.5 inches from left edge or 3 spaces right of center
      // AFH 33-337: Start on fifth line below last line of text
      v(5em)
      align(left)[
        // 4.5in from left edge minus 1in margin
        #pad(left: 4.5in - 1in)[
          #text(hyphenate: false)[
            #for line in data.signature_block {
              par(hanging-indent: 1em, justify: false)[#line]
            }
          ]
        ]
      ]
      
      // Attachments - AFH 33-337: at left margin, third line below signature element
      if data.attachments.len() > 0 {
        let leading_space = v_closing_leading_space(true, false)
        v(leading_space)
        let num = data.attachments.len()
        let label = (if num == 1 { "Attachment:" } else { str(num) + " Attachments:" })
        
        [#label]
        parbreak()
        enum(..data.attachments, numbering: "1.")
      }
      
      // cc - AFH 33-337: flush left, second line below attachment OR third line below signature
      if data.cc.len() > 0 {
        let leading_space = v_closing_leading_space(not data.attachments.len() > 0, data.attachments.len() > 0)
        v(leading_space)
        [cc:]
        parbreak()
        data.cc.join("\n")
      }
    }
  }
  
  return data
}



//=====Main Template=====
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
  pagebreak_closing: false,
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
  _process_body(body, base-par)

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

  if pagebreak_closing and (has_attachments or has_cc or has_distribution) {
    pagebreak(weak:true)
  }
  
  // Attachments
  if has_attachments {
    let leading_space = v_closing_leading_space(true)
    v_closing_leading_space(true)
    let num = attachments.len()
    let label = if num == 1 { "Attachment:" } else { str(num) + " Attachments:" }
    let continuation = (if num == 1 { "Attachment" } else { str(num) + " Attachments" }) + " (listed on next page):"
    _render_closing_section(attachments, label, numbering_style: "1.", continuation_label: continuation)
  }

  // cc
  if has_cc {
    v_closing_leading_space(not has_attachments)
    _render_closing_section(cc, "cc:")
  }

  // Distribution
  if has_distribution {
    v_closing_leading_space(not (has_attachments or has_cc))
    _render_closing_section(distribution, "DISTRIBUTION:")
  }

  // Indorsements
  if indorsements.len() > 0 {
    for indorsement in indorsements {
      (indorsement.render)(body_font: body_font)
    }
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