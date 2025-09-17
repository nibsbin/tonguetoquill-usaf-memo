// lib.typ: A Typst template backend for AFH 33-337 compliant official memorandums.

#import "utils.typ": *

//===Global State and defaults===

/// Global state container for the main memorandum data structure.
/// Tracks the primary memo information for use by indorsements and other components.
/// -> state
#let MAIN_MEMO = state("main-memo-state", none) // Tracks if we are in the main memo or indorsements

/// Default font families for letterhead text, prioritizing military standard fonts.
/// Falls back through list if fonts are unavailable on the system.
/// -> array
#let DEFAULT_LETTERHEAD_FONTS = ("Copperplate CC",)

/// Default font families for body text, complying with AFH 33-337 requirements.
/// Prioritizes Times New Roman with TeX Gyre Termes as open-source fallback.
/// -> array
#let DEFAULT_BODY_FONTS = ("times new roman","tex gyre termes")

//===Rendering Functions===

/// Renders the document letterhead section.
/// - title (str): Primary organization title.
/// - caption (str): Sub-organization or command.
/// - seal-path (str): Seal image to place in the letterhead.
/// - font (str): Font for letterhead text.
/// -> content
#let render-letterhead(title, caption, letterhead-seal, font) = {
  //Normalize to array
  if type(font) != array {
    if type(font) != str {
      font = ()
    }
    else{
      font = (font,)
    }
  }
  place(
    dy: 0.625in - spacing.margin, // 5/8in from top of page
    box(
      width: 100%,
      //height: 1.75in - .625in, // 1.75in from top of page minus 5/8in from top margin
      fill: none,
      stroke: none,
      [
        #place(
          center + top,
          align(center)[
            #text(12pt, font: font, fill: rgb("#000099"))[#title]\
            #text(10.5pt, font: font, fill: rgb("#000099"))[#caption]
          ],
        )
      ],
    ),
  )
  if letterhead-seal != none {
    place(
      left + top,
      dx: -0.5in,
      dy: -.5in,
      block[
        #fit-box(width: 2in, height: 1in)[#letterhead-seal]
      ],
    )
  }
}

/// Renders the date section (right-aligned).
/// - date (datetime): The date to display.
/// -> content
#let render-date-section(date) = {
  align(right)[#display-date(date)]
}

/// Renders the MEMORANDUM FOR section.
/// - recipients (str | array): Recipient organization(s).
/// - columns (int): Number of columns for recipient grid.
/// -> content
#let render-for-section(recipients, cols) = {
  blank-line()
  grid(
    columns: (auto, spacing.two-spaces, 1fr),
    "MEMORANDUM FOR",
    "",
    align(left)[
      #if type(recipients) == array {
        create-auto-grid(recipients, column-gutter: spacing.tab, cols: cols)
      } else {
        recipients
      }
    ],
  )
}

/// Renders the FROM section.
/// - from-info (array): Sender information array.
/// -> content
#let render-from-section(from-info) = {
  blank-line()
  //if from-info is an array, join with newlines
  if type(from-info) == array {
    from-info = from-info.join("\n")
  }

  grid(
    columns: (auto, spacing.two-spaces, 1fr),
    "FROM:", "", align(left)[#from-info],
  )
}

/// Renders the SUBJECT section.
/// - subject-text (str): Memorandum subject line.
/// -> content
#let render-subject-section(subject-text) = {
  blank-line()
  grid(
    columns: (auto, spacing.two-spaces, 1fr),
    "SUBJECT:", "", [#subject-text],
  )
}

/// Renders the optional references section.
/// - references (array): Array of reference documents.
/// -> content
#let render-references-section(references) = {
  if not falsey(references) {
    blank-line()
    grid(
      columns: (auto, spacing.two-spaces, 1fr),
      "References:", "", enum(..references, numbering: "(a)"),
    )
  }
}

/// Renders a signature block with proper AFH 33-337 formatting and orphan prevention.
/// Per AFH 33-337: "The signature block is never on a page by itself."
/// - signature-lines (array): Array of signature lines.
/// -> content
#let render-signature-block(signature-lines) = {
  blank-lines(5, weak: false)
  block(breakable: false)[
    #align(left)[
      #pad(left: 4.5in - spacing.margin)[
        #text(hyphenate: false)[
          #for line in signature-lines {
            par(hanging-indent: 1em, justify: false)[#line]
          }
        ]
      ]
    ]
  ]
}

/// Processes document body content with automatic paragraph numbering.
/// - content (content): Document body content.
/// -> content
#let render-body(content) = {
  counter("par-counter-0").update(1)
  let s = state("par-count", 0)

  context {
    // Embed enum processing to calculate paragraph levels
    let processed_content = context {
      //erase enums
      show enum.item: _enum_item => {}
      show list.item: _enum_item => {}


      // Hacky way to track enum level
      let enum-level = state("enum-level", 1)


      // Convert enums to SET_LEVEL paragraphs
      show enum.item: _enum_item => {
        context {
          enum-level.update(l => l + 1)
          SET_LEVEL(enum-level.get())
          let paragraph = _enum_item.body
          _enum_item

          //Empty vertical space to force paragraph segmentation
          v(0em, weak: true)
          _enum_item.body
          SET_LEVEL(0)
          enum-level.update(l => l - 1)
        }
      }

      // Convert lists to SET_LEVEL paragraphs
      // Treat lists the same as enums for paragraph numbering
      show list.item: list_item => {
        context {
          enum-level.update(l => l + 1)
          SET_LEVEL(enum-level.get())
          let paragraph = list_item.body
          list_item

          //Empty vertical space to force paragraph segmentation
          v(0em, weak: true)
          list_item.body
          SET_LEVEL(0)
          enum-level.update(l => l - 1)
        }
      }
      content
    }

    //Count total paragraphs in body
    let total-par-counter = counter("total-par-counter")
    total-par-counter.update(0)

    let total-par-count-content = {
      SET_LEVEL(0)
      show par: it => {
        context {
          total-par-counter.step()
        }
      }
      processed_content
    }

    // Wrap all paragraphs with memo-par
    // Use separate counter to detect last paragraph
    let par-counter = counter("par-counter")
    par-counter.update(1)
    context {
      show par: it => {
        context {
          blank-line()
          par-counter.step()
          let cur_count = par-counter.get().at(0)
          let par_count = total-par-counter.get().at(0)
          
          // Get paragraph content without creating new paragraphs
          let level = PAR_LEVEL_STATE.get()
          let paragraph-number = generate-paragraph-number(level, increment: true)
          counter(paragraph-config.counter-prefix + str(level + 1)).update(1)
          let indent-width = calculate-paragraph-indent(level)
          
          let formatted-paragraph = {
            if paragraph-config.block-indent-state.get() {
              pad(left: indent-width)[#paragraph-number#h(spacing.two-spaces)#it]
            } else {
              pad(left: 0em)[#h(indent-width)#paragraph-number#h(spacing.two-spaces)#it]
            }
          }
          
          //Check if this is the last paragraph
          if cur_count == par_count {
            block(breakable: true)[#formatted-paragraph]
          } else {
            block(breakable: true)[#formatted-paragraph]
          }
        }
      }
      total-par-count-content
      SET_LEVEL(0)
      processed_content
    }
    
  }
}

/// Renders all backmatter sections with proper spacing and page breaks.
/// - attachments (array): Array of attachment descriptions.
/// - cc (array): Array of courtesy copy recipients.
/// - distribution (array): Array of distribution list entries.
/// - leading-backmatter-pagebreak (bool): Whether to force page break before backmatter.
/// -> content
#let render-backmatter-sections(
  attachments: none,
  cc: none,
  distribution: none,
  leading-backmatter-pagebreak: false,
) = {
  let has-backmatter = (
    (attachments != none and attachments.len() > 0)
      or (cc != none and cc.len() > 0)
      or (distribution != none and distribution.len() > 0)
  )

  if leading-backmatter-pagebreak and has-backmatter {
    pagebreak(weak: true)
  }

  // Attachments section
  if attachments != none and attachments.len() > 0 {
    calculate-backmatter-spacing(true)
    let attachment-count = attachments.len()
    let section-label = if attachment-count == 1 { "Attachment:" } else { str(attachment-count) + " Attachments:" }
    let continuation-label = (
      (if attachment-count == 1 { "Attachment" } else { str(attachment-count) + " Attachments" })
        + " (listed on next page):"
    )
    render-backmatter-section(attachments, section-label, numbering-style: "1.", continuation-label: continuation-label)
  }

  // Courtesy copies section
  if cc != none and cc.len() > 0 {
    calculate-backmatter-spacing(attachments == none or attachments.len() == 0)
    render-backmatter-section(cc, "cc:")
  }

  // Distribution section
  if distribution != none and distribution.len() > 0 {
    calculate-backmatter-spacing((attachments == none or attachments.len() == 0) and (cc == none or cc.len() == 0))
    render-backmatter-section(distribution, "DISTRIBUTION:")
  }
}

// =============================================================================
// INDORSEMENT DATA STRUCTURE
// =============================================================================

/// Creates an indorsement object for routing memorandums through multiple offices.
/// Indorsements provide coordination and approval routing per AFH 33-337 standards.
/// Each indorsement represents one office's review and forwarding of the original memo.
/// 
/// Use this function to create indorsement objects, then include them in the 
/// indorsements array of the main official-memorandum() function.
/// 
/// - office-symbol (str): Sending organization symbol (default: "ORG/SYMBOL").
/// - memo-for (str): Recipient organization symbol (default: "ORG/SYMBOL").
/// - signature-block (array): Array of signature lines (name/rank, title, organization).
/// - attachments (array): Array of attachment descriptions specific to this indorsement.
/// - cc (array): Array of courtesy copy recipients for this indorsement.
/// - leading-pagebreak (bool): Whether to force page break before indorsement (default: false).
/// - separate-page (bool): Whether to use separate-page indorsement format (default: false).
/// - indorsement-date (datetime): Date of the indorsement (default: today).
/// - body (content): **REQUIRED** - Indorsement body content (routing comments, instructions).
/// -> dictionary
#let indorsement(
  office-symbol: "ORG/SYMBOL",
  memo-for: "ORG/SYMBOL",
  signature-block: (
    "FIRST M. LAST, Rank, USAF",
    "Duty Title",
    "Organization (if not on letterhead)",
  ),
  attachments: none,
  cc: none,
  leading-pagebreak: false,
  separate-page: false,
  indorsement-date: datetime.today(),
  body,
) = {
  let ind = (
    office-symbol: office-symbol,
    memo-for: memo-for,
    signature-block: signature-block,
    attachments: attachments,
    cc: cc,
    leading-pagebreak: leading-pagebreak,
    separate-page: separate-page,
    body: body,
  )

  /// Renders the indorsement with proper formatting.
  /// - body-font (str): Font to use for body text.
  /// -> content
  ind.render = (body-font: DEFAULT_BODY_FONTS ) => configure(body-font, {
    counters.indorsement.step()

    context {
      let main-memo = MAIN_MEMO.get()
      assert(type(main-memo) != none,message: "Internal error: MAIN_MEMO state not initialized.")
      let original-date = datetime.today()
      // Get original subject from main-memo
      let original-subject = main-memo.subject
      // Extract original-office from memo-from; if multiple lines, use the first line
      let original-office = if type(main-memo.memo-from) == array {
          main-memo.memo-from.at(0)
        } else {
          main-memo.memo-from
        }

      let indorsement-number = counters.indorsement.get().first()
      let indorsement-label = format-indorsement-number(indorsement-number)

      if ind.leading-pagebreak or separate-page {
        pagebreak()
      }

      if ind.separate-page {
        // Separate-page indorsement format per AFH 33-337
        [#indorsement-label to #original-office, #display-date(original-date), #original-subject]

        blank-line()
        grid(
          columns: (auto, 1fr),
          ind.office-symbol, align(right)[#display-date(indorsement-date)],
        )

        blank-line()
        grid(
          columns: (auto, spacing.two-spaces, 1fr),
          "MEMORANDUM FOR", "", ind.memo-for,
        )
      } else {
        // Standard indorsement format
        // Add spacing only if we didn't just do a pagebreak
        if not ind.leading-pagebreak {
          blank-line()
        }
        [#indorsement-label, #ind.office-symbol]

        blank-line()
        grid(
          columns: (auto, spacing.two-spaces, 1fr),
          "MEMORANDUM FOR", "", ind.memo-for,
        )
      }
      // Render body content
      render-body(ind.body)

      // Signature block positioning per AFH 33-337
      render-signature-block(ind.signature-block)


      // Attachments section
      if not falsey(ind.attachments) {
        calculate-backmatter-spacing(true)
        let attachment-count = ind.attachments.len()
        let section-label = if attachment-count == 1 { "Attachment:" } else { str(attachment-count) + " Attachments:" }

        [#section-label]
        parbreak()
        enum(..ind.attachments, numbering: "1.")
      }

      // Courtesy copies section
      if not falsey((ind.cc)) {
        calculate-backmatter-spacing(falsey(ind.attachments))
        [cc:]
        parbreak()
        ind.cc.join("\n")
      }
    }
  })

  return ind
}


// =============================================================================
// MAIN MEMORANDUM TEMPLATE
// =============================================================================

/// Creates an official memorandum following AFH 33-337 "The Tongue and Quill" standards.
/// Generates a fully formatted military memorandum with automatic paragraph numbering,
/// proper spacing, letterhead formatting, and intelligent page break handling.
/// 
/// Only memo-for and subject are required; all other parameters have sensible defaults.
/// Supports multiple recipients, attachments, distribution lists, and routing indorsements.
/// 
/// - letterhead-title (str): Primary organization title (default: "DEPARTMENT OF THE AIR FORCE").
/// - letterhead-caption (str): Sub-organization or unit name (default: placeholder text).
/// - letterhead-seal (content): Organization seal image for letterhead (default: none).
/// - date (datetime): Date of the memorandum; defaults to today if not provided.
/// - memo-for (str | array): **REQUIRED** - Recipient organization(s). Can be string or array.
/// - memo-from (array): Sender information as array of strings (organization, address lines).
/// - subject (str): **REQUIRED** - Memorandum subject line in title case.
/// - references (array): Optional array of reference documents for citations.
/// - signature-block (array): Array of signature lines (name, title, organization).
/// - attachments (array): Array of attachment descriptions.
/// - cc (array): Array of courtesy copy recipients.
/// - distribution (array): Array of distribution list entries.
/// - indorsements (array): Array of indorsement objects created with indorsement().
/// - letterhead-font (str | array): Font(s) for letterhead text (default: Copperplate CC).
/// - body-font (str | array): Font(s) for body text (default: Times New Roman/TeX Gyre Termes).
/// - memo-for-cols (int): Number of columns for recipient grid layout (default: 3).
/// - paragraph-block-indent (bool): Enable paragraph block indentation (default: false).
/// - leading-backmatter-pagebreak (bool): Force page break before backmatter sections (default: false).
/// - body (content): Main memorandum content with automatic paragraph numbering.
/// -> content
#let official-memorandum(
  letterhead-title: "DEPARTMENT OF THE AIR FORCE",
  letterhead-caption: "[YOUR SQUADRON/UNIT NAME]",
  letterhead-seal: none,
  date: none,
  memo-for: (
    "[FIRST/OFFICE]", "[SECOND/OFFICE]", "[THIRD/OFFICE]", "[FOURTH/OFFICE]", "[FIFTH/OFFICE]", "[SIXTH/OFFICE]"
  ),
  memo-from: (
    "[YOUR/SYMBOL]",
    "[Your Organization Name]",
    "[Street Address]",
    "[City ST 12345-6789]",
  ),
  subject: "[Your Subject in Title Case - Required Field]",
  references: none,
  signature-block: (
    "[FIRST M. LAST, Rank, USAF]",
    "[Your Official Duty Title]",
    "[Organization (optional)]",
  ),
  attachments: none,
  cc: none,
  distribution: none,
  indorsements: none,
  // Optional styling parameters
  letterhead-font: DEFAULT_LETTERHEAD_FONTS,
  body-font: DEFAULT_BODY_FONTS,
  memo-for-cols: 3,
  paragraph-block-indent: false,
  leading-backmatter-pagebreak: false,
  body,
) = configure(body-font, {
  // Initialize document counters and settings

  let self = (
    letterhead-title: letterhead-title,
    letterhead-caption: letterhead-caption,
    letterhead-seal: letterhead-seal,
    date: if date == none { datetime.today() } else { date },
    memo-for: memo-for,
    memo-from: memo-from,
    subject: subject,
    references: references,
    signature-block: signature-block,
    attachments: attachments,
    cc: cc,
    distribution: distribution,
    indorsements: indorsements,
    letterhead-font: letterhead-font,
    body-font: body-font,
    memo-for-cols: memo-for-cols,
    paragraph-block-indent: paragraph-block-indent,
    leading-backmatter-pagebreak: leading-backmatter-pagebreak,
    body: body,
  )
  MAIN_MEMO.update(self)

  counters.indorsement.update(0)
  set page(
    paper: "us-letter",
    margin: (left: spacing.margin, right: spacing.margin, top: spacing.margin, bottom: spacing.margin),
  )
  paragraph-config.block-indent-state.update(self.paragraph-block-indent)

  // Page numbering starting from page 2
  context {
    if counter(page).get().first() > 1 {
      place(
        top + right,
        dx: 0in,
        dy: -0.5in,
        text(12pt)[#counter(page).display()],
      )
    }
  }

  // Document letterhead
  render-letterhead(self.letterhead-title, self.letterhead-caption, self.letterhead-seal, self.letterhead-font)

  // Document header sections
  v(1.75in - spacing.margin) // 1.75in from top of the page
  context {
    render-date-section(self.date)
  }
  render-for-section(self.memo-for, self.memo-for-cols)
  render-from-section(self.memo-from)
  render-subject-section(self.subject)
  render-references-section(self.references)

  // Main document body
  // Render body content
  render-body(self.body)

  // Signature block positioning per AFH 33-337
  render-signature-block(self.signature-block)

  // Backmatter sections with proper spacing and page breaks
  render-backmatter-sections(
    attachments: self.attachments,
    cc: self.cc,
    distribution: self.distribution,
    leading-backmatter-pagebreak: self.leading-backmatter-pagebreak,
  )

  // Indorsements
  process-indorsements(self.indorsements, body-font: self.body-font)
})

