// primitives.typ: Reusable rendering primitives for USAF memorandum sections

#import "config.typ": *
#import "utils.typ": *

// =============================================================================
// LETTERHEAD RENDERING
// =============================================================================

#let render-letterhead(title, caption, letterhead-seal, font) = {
  if type(font) != array {
    if type(font) != str {
      font = ()
    } else {
      font = (font,)
    }
  }

  if type(caption) == array {
    caption = caption.join("\n")
  }

  place(
    dy: 0.625in - spacing.margin,
    box(
      width: 100%,
      fill: none,
      stroke: none,
      [
        #place(
          center + top,
          align(center)[
            #text(12pt, font: font, fill: LETTERHEAD_COLOR)[#title]\
            #text(10.5pt, font: font, fill: LETTERHEAD_COLOR)[#caption]
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

// =============================================================================
// HEADER SECTIONS
// =============================================================================

#let render-date-section(date) = {
  align(right)[#display-date(date)]
}

#let render-for-section(recipients, cols) = {
  blank-line()
  grid(
    columns: (auto, auto, 1fr),
    "MEMORANDUM FOR",
    "  ",
    align(left)[
      #if type(recipients) == array {
        create-auto-grid(recipients, column-gutter: spacing.tab, cols: cols)
      } else {
        recipients
      }
    ],
  )
}

#let render-from-section(from-info) = {
  blank-line()
  if type(from-info) == array {
    from-info = from-info.join("\n")
  }

  grid(
    columns: (auto, auto, 1fr),
    "FROM:", "  ", align(left)[#from-info],
  )
}

#let render-subject-section(subject-text) = {
  blank-line()
  grid(
    columns: (auto, auto, 1fr),
    "SUBJECT:", "  ", [#subject-text],
  )
}

#let render-references-section(references) = {
  if not falsey(references) {
    blank-line()
    grid(
      columns: (auto, auto, 1fr),
      "References:", "  ", enum(..references, numbering: "(a)"),
    )
  }
}

// =============================================================================
// SIGNATURE BLOCK
// =============================================================================

#let render-signature-block(signature-lines, signature-blank-lines: 4) = {
  // AFH 33-337: "The signature block is never on a page by itself"
  // Note: Perfect enforcement isn't feasible without over-engineering
  // We use weak: false spacing and breakable: false to discourage orphaning
  blank-lines(signature-blank-lines, weak: false)
  block(breakable: false)[
    #align(left)[
      #pad(left: 4.5in - spacing.margin)[
        #text(hyphenate: false)[
          #signature-lines.join(linebreak())
        ]
      ]
    ]
  ]
}

// =============================================================================
// BACKMATTER SECTIONS
// =============================================================================

#let render-backmatter-section(
  content,
  section-label,
  numbering-style: none,
  continuation-label: none
) = {
  let formatted-content = {
    // Use text() wrapper to prevent section label from being treated as a paragraph
    text()[#section-label]
    linebreak()
    if numbering-style != none {
      let items = if type(content) == array { content } else { (content,) }
      enum(..items, numbering: numbering-style)
    } else {
      if type(content) == array {
        content.join("\n")
      } else {
        content
      }
    }
  }

  context {
    let available-space = page.height - here().position().y - 1in
    if measure(formatted-content).height > available-space {
      let continuation-text = if continuation-label != none {
        text()[#continuation-label]
      } else {
        text()[#section-label + " (listed on next page):"]
      }
      continuation-text
      pagebreak()
    }
    formatted-content
  }
}

#let calculate-backmatter-spacing(is-first-section) = {
  context {
    let line_count = if is-first-section { 2 } else { 1 }
    blank-lines(line_count)
  }
}

#let render-backmatter-sections(
  attachments: none,
  cc: none,
  distribution: none,
  leading-pagebreak: false,
) = {
  let has-backmatter = (
    (attachments != none and attachments.len() > 0)
      or (cc != none and cc.len() > 0)
      or (distribution != none and distribution.len() > 0)
  )

  if leading-pagebreak and has-backmatter {
    pagebreak(weak: true)
  }

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

  if cc != none and cc.len() > 0 {
    calculate-backmatter-spacing(attachments == none or attachments.len() == 0)
    render-backmatter-section(cc, "cc:")
  }

  if distribution != none and distribution.len() > 0 {
    calculate-backmatter-spacing((attachments == none or attachments.len() == 0) and (cc == none or cc.len() == 0))
    render-backmatter-section(distribution, "DISTRIBUTION:")
  }
}

// =============================================================================
// PARAGRAPH BODY RENDERING
// =============================================================================

/// Attempt to detect multiple paragraphs by examining raw markup
#let detect-multiple-paragraphs(content) = {
  // Try to get string representation of content
  let content-str = repr(content)

  // Look for patterns that indicate paragraph breaks:
  // - Double newlines in various forms
  // - Multiple spaces/newlines that suggest paragraph separation
  let has-double-newline = content-str.contains("\n\n") or content-str.contains("\\n\\n")
  let has-parbreak = content-str.contains("parbreak()")

  return has-double-newline or has-parbreak
}

#let render-paragraph-body(content) = {
  // Initialize base level counter
  counter("par-counter-0").update(1)

  // AFH 33-337: "Number and letter each paragraph and subparagraph. A single
  // paragraph is not numbered."
  // Auto-detect by parsing raw markup for paragraph breaks
  let should-number = detect-multiple-paragraphs(content)

  // Render content with paragraph numbering
  {
    // Track nesting level for enum/list items
    let enum-level = state("enum-level", 1)

    // Suppress default enum/list rendering - we'll handle it via nested paragraphs
    show enum.item: _enum_item => {}
    show list.item: _list_item => {}

    // Intercept enum items to set nesting level
    show enum.item: _enum_item => context {
      enum-level.update(l => l + 1)
      SET_LEVEL(enum-level.get())

      // Don't render the enum marker - render body content as nested paragraphs instead
      v(0em, weak: true)
      _enum_item.body

      // Reset level after nested content
      SET_LEVEL(0)
      enum-level.update(l => l - 1)
    }

    // Intercept list items to set nesting level
    show list.item: list_item => context {
      enum-level.update(l => l + 1)
      SET_LEVEL(enum-level.get())

      // Don't render the list marker - render body content as nested paragraphs instead
      v(0em, weak: true)
      list_item.body

      // Reset level after nested content
      SET_LEVEL(0)
      enum-level.update(l => l - 1)
    }

    // Intercept paragraphs for numbering
    show par: it => context {
      // Check if we're in backmatter - if so, don't number paragraphs
      if IN_BACKMATTER_STATE.get() {
        it
      } else {
        blank-line()
        if should-number {
          // Apply paragraph numbering per AFH 33-337
          let paragraph = memo-par([#it.body])
          // Apply widow/orphan prevention (AFH 33-337: at least 2 lines per page)
          set text(costs: (orphan: 0%))
          block(breakable: true)[#paragraph]
        } else {
          // No numbering (for rare single-paragraph memos)
          // Return body content wrapped in block (like numbered case, but without numbering)
          set text(costs: (orphan: 0%))
          block(breakable: true)[#it.body]
        }
      }
    }

    // Reset to base level and render content
    SET_LEVEL(0)
    content
  }
}
