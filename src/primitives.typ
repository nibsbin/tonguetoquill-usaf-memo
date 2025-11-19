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
  blank-lines(signature-blank-lines, weak: false)
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
    [#section-label]
    parbreak()
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
        continuation-label
      } else {
        section-label + " (listed on next page):"
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

#let render-paragraph-body(content) = {
  counter("par-counter-0").update(1)
  let s = state("par-count", 0)

  context {
    let processed_content = context {
      show enum.item: _enum_item => {}
      show list.item: _enum_item => {}

      let enum-level = state("enum-level", 1)

      show enum.item: _enum_item => {
        context {
          enum-level.update(l => l + 1)
          SET_LEVEL(enum-level.get())
          let paragraph = _enum_item.body
          _enum_item

          v(0em, weak: true)
          _enum_item.body
          SET_LEVEL(0)
          enum-level.update(l => l - 1)
        }
      }

      show list.item: list_item => {
        context {
          enum-level.update(l => l + 1)
          SET_LEVEL(enum-level.get())
          let paragraph = list_item.body
          list_item

          v(0em, weak: true)
          list_item.body
          SET_LEVEL(0)
          enum-level.update(l => l - 1)
        }
      }
      content
    }

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

    let par-counter = counter("par-counter")
    par-counter.update(1)
    context {
      show par: it => {
        context {
          blank-line()
          par-counter.step()
          let cur_count = par-counter.get().at(0)
          let par_count = total-par-counter.get().at(0)
          let paragraph = memo-par([#it.body])
          if cur_count == par_count {
            set text(costs: (orphan: 0%))
            block(breakable: true, sticky: true)[#paragraph]
          } else {
            block(breakable: true)[#paragraph]
          }
        }
      }
      total-par-count-content
      SET_LEVEL(0)
      processed_content
    }
  }
}
