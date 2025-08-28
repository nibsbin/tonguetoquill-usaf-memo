// lib.typ: A Typst template for AFH 33-337 compliant official memorandums.
#import "utils.typ": *

// =============================================================================
// USER-FACING PARAGRAPH FUNCTIONS
// =============================================================================

/// Paragraph functions with automatic numbering and proper indentation
/// These provide a convenient interface for hierarchical document structure

/// First-level subparagraph (numbered a., b., c., etc.)
#let sub-par(content) = create-numbered-paragraph(content, level: 1)

/// Second-level subparagraph (numbered (1), (2), (3), etc.)
#let sub-sub-par(content) = create-numbered-paragraph(content, level: 2)

/// Third-level subparagraph (numbered (a), (b), (c), etc.)
#let sub-sub-sub-par(content) = create-numbered-paragraph(content, level: 3)

/// Fourth-level subparagraph (numbered with underlined numbers)
#let sub-sub-sub-sub-par(content) = create-numbered-paragraph(content, level: 4)

/// Fifth-level subparagraph (numbered with underlined letters)
#let sub-sub-sub-sub-sub-par(content) = create-numbered-paragraph(content, level: 5)

// =============================================================================
// INDORSEMENT DATA STRUCTURE
// =============================================================================

/// Creates an indorsement object with proper AFH 33-337 formatting
/// @param office_symbol: Sending organization symbol
/// @param memo_for: Recipient organization symbol  
/// @param signature_block: Array of signature lines
/// @param attachments: Array of attachment descriptions
/// @param cc: Array of courtesy copy recipients
/// @param leading_pagebreak: Whether to force page break before indorsement
/// @param separate_page: Whether to use separate-page indorsement format
/// @param original_office: Original memo's office symbol (for separate-page format)
/// @param original_date: Original memo's date (for separate-page format)
/// @param original_subject: Original memo's subject (for separate-page format)
/// @param body: Indorsement body content
/// @returns: Indorsement object with render method
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
  leading_pagebreak: false,
  separate_page: false,
  original_office: none,
  original_date: none,
  original_subject: none,
  body
) = {
  let indorsement-data = (
    office-symbol: office_symbol,
    memo-for: memo_for,
    signature-block: signature_block,
    attachments: attachments,
    cc: cc,
    leading-pagebreak: leading_pagebreak,
    separate-page: separate_page,
    original-office: original_office,
    original-date: original_date,
    original-subject: original_subject,
    body: body,
  )
  
  /// Renders the indorsement with proper formatting
  /// @param body_font: Font to use for body text
  /// @returns: Formatted indorsement content
  indorsement-data.render = (body-font: "Times New Roman") => {
    let current-date = datetime.today().display("[day] [month repr:short] [year]")
    counters.indorsement.step()
    
    context {
      set text(font: body-font, size: 12pt)
      set par(leading: spacing.line, spacing: .5em, justify: true)
      
      let indorsement-number = counters.indorsement.get().first()
      let indorsement-label = format-indorsement-number(indorsement-number)
      
      if indorsement-data.leading-pagebreak {
        pagebreak()
      }
      
      if indorsement-data.separate-page and indorsement-data.original-office != none {
        // Separate-page indorsement format per AFH 33-337
        [#indorsement-label to #indorsement-data.original-office, #current-date, #indorsement-data.original-subject]
        
        v(spacing.paragraph)
        grid(
          columns: (auto, 1fr),
          indorsement-data.office-symbol,
          align(right)[#current-date]
        )
        
        v(spacing.paragraph)
        grid(
          columns: (auto, spacing.two-spaces, 1fr),
          "MEMORANDUM FOR", "", indorsement-data.memo-for
        )
      } else {
        // Standard indorsement format
        v(spacing.paragraph)
        [#indorsement-label, #indorsement-data.office-symbol]
        
        v(spacing.paragraph)
        grid(
          columns: (auto, spacing.two-spaces, 1fr),
          "MEMORANDUM FOR", "", indorsement-data.memo-for
        )
      }
      
      // Render body content if provided
      if indorsement-data.body != none {
        v(spacing.paragraph)
        process-document-body(indorsement-data.body)
      }
      
      // Signature block positioning per AFH 33-337
      v(5em)
      align(left)[
        #pad(left: 4.5in - 1in)[
          #text(hyphenate: false)[
            #for line in indorsement-data.signature-block {
              par(hanging-indent: 1em, justify: false)[#line]
            }
          ]
        ]
      ]
      
      // Attachments section
      if indorsement-data.attachments.len() > 0 {
        calculate-backmatter-spacing(true)
        let attachment-count = indorsement-data.attachments.len()
        let section-label = if attachment-count == 1 { "Attachment:" } else { str(attachment-count) + " Attachments:" }
        
        [#section-label]
        parbreak()
        enum(..indorsement-data.attachments, numbering: "1.")
      }
      
      // Courtesy copies section
      if indorsement-data.cc.len() > 0 {
        calculate-backmatter-spacing(indorsement-data.attachments.len() == 0)
        [cc:]
        parbreak()
        indorsement-data.cc.join("\n")
      }
    }
  }
  
  return indorsement-data
}



// =============================================================================
// INTERNAL RENDERING FUNCTIONS
// =============================================================================

/// Renders the document letterhead section
#let render-letterhead(title, caption, seal-path, font) = {
  box(
    width: 100%,
    height: 0.75in,
    fill: none,
    stroke: none,
    [
      #place(
        center + top,
        align(center)[
          #text(12pt, weight: "bold", font: font)[#title]\
          #text(10.5pt, weight: "bold", font: font, fill: luma(24%))[#caption]
        ]
      )
      
      #place(
        left + horizon,
        dx: -0.25in,
        dy: -0.125in,
        image(seal-path, width: 1in, height: 2in, fit: "contain")
      )
    ]
  )
}

/// Renders the date section (right-aligned)
#let render-date-section() = {
  align(right)[#datetime.today().display("[day] [month repr:long] [year]")]
}

/// Renders the MEMORANDUM FOR section
#let render-memo-for-section(recipients) = {
  v(spacing.paragraph)
  grid(
    columns: (auto, spacing.two-spaces, 1fr),
    "MEMORANDUM FOR", "",
    align(left)[
      #if type(recipients) == array {
        create-auto-grid(recipients, column-gutter: spacing.tab)
      } else {
        recipients
      }
    ]
  )
}

/// Renders the FROM section
#let render-from-section(from-info) = {
  v(spacing.paragraph)
  grid(
    columns: (auto, spacing.two-spaces, 1fr),
    "FROM:", "",
    align(left)[#from-info.join("\n")]
  )
}

/// Renders the SUBJECT section
#let render-subject-section(subject-text) = {
  v(spacing.paragraph)
  grid(
    columns: (auto, spacing.two-spaces, 1fr),
    "SUBJECT:", "", [#subject-text]
  )
}

/// Renders the optional references section
#let render-references-section(references) = {
  if references.len() > 0 {
    v(spacing.paragraph)
    grid(
      columns: (auto, spacing.two-spaces, 1fr),
      "References:", "", enum(..references, numbering: "(a)")
    )
  }
}

/// Renders the signature block with intelligent page break handling
#let render-signature-block(signature-lines) = {
  context {
    let signature-content = {
      v(5em)
      align(left)[
        #pad(left: 4.5in - 1in)[
          #text(hyphenate: false)[
            #for line in signature-lines {
              par(hanging-indent: 1em, justify: false)[#line]
            }
          ]
        ]
      ]
    }
    
    let available-space = page.height - here().position().y - 1in
    let signature-height = measure(signature-content).height
    
    if signature-height > available-space {
      pagebreak(weak: true)
    }
    
    signature-content
  }
}

/// Renders all backmatter sections with proper spacing and page breaks
#let render-backmatter-sections(
  attachments: (),
  cc: (),
  distribution: (),
  force-pagebreak: false
) = {
  let has-any-backmatter = attachments.len() > 0 or cc.len() > 0 or distribution.len() > 0
  
  if force-pagebreak and has-any-backmatter {
    pagebreak(weak: true)
  }
  
  // Attachments section
  if attachments.len() > 0 {
    calculate-backmatter-spacing(true)
    let attachment-count = attachments.len()
    let section-label = if attachment-count == 1 { "Attachment:" } else { str(attachment-count) + " Attachments:" }
    let continuation-label = (if attachment-count == 1 { "Attachment" } else { str(attachment-count) + " Attachments" }) + " (listed on next page):"
    render-backmatter-section(attachments, section-label, numbering-style: "1.", continuation-label: continuation-label)
  }

  // Courtesy copies section
  if cc.len() > 0 {
    calculate-backmatter-spacing(attachments.len() == 0)
    render-backmatter-section(cc, "cc:")
  }

  // Distribution section
  if distribution.len() > 0 {
    calculate-backmatter-spacing(attachments.len() == 0 and cc.len() == 0)
    render-backmatter-section(distribution, "DISTRIBUTION:")
  }
}

// =============================================================================
// MAIN MEMORANDUM TEMPLATE
// =============================================================================

/// Creates an official memorandum following AFH 33-337 standards
/// @param letterhead_title: Primary organization title
/// @param letterhead_caption: Sub-organization or command
/// @param letterhead_seal: Path to organization seal image
/// @param memo_for: Recipient(s) - string, array, or nested array for grid layout
/// @param from_block: Sender information as array of strings
/// @param subject: Memorandum subject line
/// @param references: Optional array of reference documents
/// @param signature_block: Array of signature lines
/// @param attachments: Array of attachment descriptions
/// @param cc: Array of courtesy copy recipients
/// @param distribution: Array of distribution list entries
/// @param indorsements: Array of Indorsement objects
/// @param letterhead_font: Font for letterhead text
/// @param body_font: Font for body text
/// @param paragraph_block_indent: Enable paragraph block indentation
/// @param force_backmatter_pagebreak: Force page break before backmatter sections
/// @param body: Main memorandum content
/// @returns: Formatted official memorandum
#let official-memorandum(
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
  letterhead-font: "Arial",
  body-font: "Times New Roman",
  paragraph-block-indent: false,
  force-backmatter-pagebreak: false,
  body
) = {
  // Initialize document counters and settings
  counters.indorsement.update(0)
  set page(
    paper: "us-letter",
    margin: (left: 1in, right: 1in, top: 1in, bottom: 1in),
  )
  set text(font: body-font, size: 12pt)
  set par(leading: spacing.line, spacing: spacing.line)
  paragraph-config.block-indent-state.update(paragraph-block-indent)

  // Page numbering starting from page 2
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

  // Document letterhead
  render-letterhead(letterhead-title, letterhead-caption, letterhead-seal, letterhead-font)

  // Document header sections
  render-date-section()
  render-memo-for-section(memo-for)
  render-from-section(from-block)
  render-subject-section(subject)
  render-references-section(references)

  // Main document body
  set par(justify: true)
  process-document-body(body)

  // Signature block with intelligent page break handling
  render-signature-block(signature-block)
  
  // Backmatter sections with proper spacing and page breaks
  render-backmatter-sections(
    attachments: attachments,
    cc: cc,
    distribution: distribution,
    force-pagebreak: force-backmatter-pagebreak
  )

  // Indorsements
  process-indorsements(indorsements, body-font: body-font)
}

// =============================================================================
// LEGACY COMPATIBILITY ALIASES
// =============================================================================

/// Legacy parameter interface for backward compatibility
/// This maintains compatibility with existing templates using hyphenated parameter names
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
  par_block_indent: false,
  pagebreak_backmatter: false,
  body
) = {
  official-memorandum(
    letterhead-title: letterhead-title,
    letterhead-caption: letterhead-caption,
    letterhead-seal: letterhead-seal,
    memo-for: memo-for,
    from-block: from-block,
    subject: subject,
    references: references,
    signature-block: signature-block,
    attachments: attachments,
    cc: cc,
    distribution: distribution,
    indorsements: indorsements,
    letterhead-font: letterhead_font,
    body-font: body_font,
    paragraph-block-indent: par_block_indent,
    pagebreak_backmatter: pagebreak_backmatter,
    body
  )
}

// =============================================================================
// EXAMPLE DOCUMENT
// =============================================================================

/// Default example memorandum demonstrating template capabilities
/// This serves as both documentation and a quick-start example
#official-memorandum()[

Welcome to the Typst USAF Memo template! This template provides automatic formatting for official Air Force memorandums according to AFH 33-337 "The Tongue and Quill" standards. This comprehensive template eliminates the tedious formatting work that typically consumes valuable time when preparing official correspondence.

The template has been meticulously designed to ensure full compliance with Air Force publishing standards while providing a streamlined user experience. Key features and capabilities include:

#sub-par[*Automatic paragraph numbering and formatting*. Paragraphs are automatically numbered using the proper Air Force hierarchy (1., a., (1), (a)) and spaced with precise line spacing. Writers can focus entirely on content while the template handles all formatting requirements including proper indentation, alignment, and spacing between elements.]

#sub-par[*Hierarchical document structure*. The template supports multi-level paragraph organization essential for complex policy documents and detailed instructions. Each subparagraph level is automatically numbered and properly indented to maintain visual clarity and regulatory compliance.]

#sub-sub-par[Implementation is straightforward: simply wrap content in the appropriate paragraph function such as `sub_par[...]` for first-level subparagraphs, `sub_sub_par[...]` for second-level, and so forth.]

#sub-par[*Smart page break handling*. The template automatically manages page breaks for backmatter sections (attachments, cc, and distribution lists) according to AFH 33-337 requirements. If a section doesn't fit on the current page, it uses proper continuation formatting with "(listed on next page)" notation, ensuring no orphaned headers or improper splits.]

#sub-par[*Complete document formatting automation*. All letterhead elements, margins, fonts, date formatting, signature block positioning, and backmatter elements are automatically configured according to AFH 33-337 specifications. This includes proper placement of the Department of Defense seal scaled to fit a 1in × 2in box while preserving aspect ratio.]

#sub-par[*Flexible content management*. The template accommodates various memorandum types including single addressee, multiple addressee, and distribution lists. Reference citations, attachments, courtesy copies, and distribution lists are all properly formatted and positioned with intelligent page break handling.]

#sub-par[*Professional presentation standards*. Typography follows Air Force requirements with 12-point Times New Roman font, proper line spacing, justified text alignment, and consistent spacing between document elements. Page numbering, when required, is automatically positioned 0.5 inches from the top of the page and flush with the right margin.]

Created by #link("https://github.com/snpm")[Nibs].

]