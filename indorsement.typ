// indorsement.typ: Implementation of AFH 33-337 indorsement formatting for Typst USAF memo template.

//=====Backend=====
//==CONFIGS
#let TWO_SPACES = .5em
#let BLANK_LINE = 1em
#let LINE_SPACING = .5em

// Indorsement counter for sequential numbering (1st Ind, 2d Ind, 3d Ind, etc.)
#let INDORSEMENT_COUNTER = counter("indorsement")

// Convert number to ordinal suffix for indorsements (1st, 2d, 3d, 4th, etc.)
#let _get_ordinal_suffix(n) = {
  let last_digit = calc.rem(n, 10)
  let last_two_digits = calc.rem(n, 100)
  
  if last_two_digits >= 11 and last_two_digits <= 13 {
    "th"
  } else if last_digit == 1 {
    "st"
  } else if last_digit == 2 {
    "d"
  } else if last_digit == 3 {
    "d"
  } else {
    "th"
  }
}

// Format indorsement number according to AFH 33-337 standards
#let _format_indorsement_number(n) = {
  let suffix = _get_ordinal_suffix(n)
  str(n) + suffix + " Ind"
}

//=====Frontend=====

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
  pagebreak: false
) = {
  (
    office_symbol: office_symbol,
    memo_for: memo_for,
    signature_block: signature_block,
    attachments: attachments,
    cc: cc,
    body: body,
    pagebreak: pagebreak
  )
}

// Render a single indorsement according to AFH 33-337 standards
#let render_indorsement(indorsement, body_font: "Times New Roman") = {
  set text(font: body_font, size: 12pt)
  set par(leading: LINE_SPACING, spacing: LINE_SPACING, justify: true)
  
  context {
    // Get current indorsement number and increment counter
    let ind_num = INDORSEMENT_COUNTER.get().first() + 1
    INDORSEMENT_COUNTER.step()
    let ind_label = _format_indorsement_number(ind_num)
    
    // Add page break if requested
    if indorsement.pagebreak {
      pagebreak()
    }
    
    // AFH 33-337: Begin indorsement on second line below last element
    v(BLANK_LINE)
    
    // Indorsement header: "1st Ind, ORG/SYMBOL"
    [#ind_label, #indorsement.office_symbol]
    
    // AFH 33-337: MEMORANDUM FOR on next line
    v(BLANK_LINE)
    grid(
      columns: (auto, TWO_SPACES, 1fr),
      "MEMORANDUM FOR", "", indorsement.memo_for
    )
    
    // Body content (if provided)
    if indorsement.body != none {
      v(BLANK_LINE)
      indorsement.body
    }
    
    // Signature Block - AFH 33-337: 4.5 inches from left edge or 3 spaces right of center
    // AFH 33-337: Start on fifth line below last line of text
    v(5em)
    align(left)[
      // 4.5in from left edge minus 1in margin
      #pad(left: 4.5in - 1in)[
        #text(hyphenate: false)[
          #for line in indorsement.signature_block {
            par(hanging-indent: 1em, justify: false)[#line]
          }
        ]
      ]
    ]
    
    // Helper function to add proper spacing for closing sections
    let add_closing_spacing(has_attachments, has_cc) = {
      if has_attachments or has_cc {
        v(2 * LINE_SPACING) // Second line below previous element
      } else {
        v(3 * LINE_SPACING) // Third line below signature if first element
      }
    }
    
    // Attachments - AFH 33-337: at left margin, third line below signature element
    if indorsement.attachments.len() > 0 {
      v(3 * LINE_SPACING)
      let num = indorsement.attachments.len()
      let label = (if num == 1 { "Attachment:" } else { str(num) + " Attachments:" })
      
      [#label]
      parbreak()
      enum(..indorsement.attachments, numbering: "1.")
    }
    
    // cc - AFH 33-337: flush left, second line below attachment OR third line below signature
    if indorsement.cc.len() > 0 {
      add_closing_spacing(indorsement.attachments.len() > 0, false)
      [cc:]
      parbreak()
      indorsement.cc.join("\n")
    }
  }
}

// Render multiple indorsements in sequence
#let render_indorsements(indorsements, body_font: "Times New Roman") = {
  // Reset indorsement counter at start
  INDORSEMENT_COUNTER.update(0)
  
  for indorsement in indorsements {
    render_indorsement(indorsement, body_font: body_font)
  }
}

// Render indorsements within the main memo template  
#let process_indorsements(indorsements, body_font: "Times New Roman") = {
  if indorsements.len() > 0 {
    render_indorsements(indorsements, body_font: body_font)
  }
}
