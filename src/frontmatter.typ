// frontmatter.typ: Frontmatter show rule for USAF memorandum
//
// This module implements the frontmatter (heading section) of a USAF memorandum
// per AFH 33-337 Chapter 14 "The Heading Section". It handles:
// - Page setup with proper margins
// - Letterhead rendering
// - Date, MEMORANDUM FOR, FROM, SUBJECT, and References placement
// - Classification markings in headers/footers

#import "primitives.typ": *

#let frontmatter(
  subject: none,
  memo-for: none,
  memo-from: none,
  date: none,
  references: none,
  letterhead-title: "DEPARTMENT OF THE AIR FORCE",
  letterhead-caption: "[YOUR SQUADRON/UNIT NAME]",
  letterhead-seal: none,
  letterhead-seal-subtitle: none, // optional line under seal (9pt bold caps); ignored if no seal
  letterhead-font: DEFAULT_LETTERHEAD_FONTS,
  body-font: DEFAULT_BODY_FONTS,
  font-size: 12pt,
  memo-for-cols: 3,
  classification-level: none,
  footer-tag-line: none,
  auto-numbering: true,
  memo-style: "usaf",
  it,
) = {
  assert(subject != none, message: "subject is required")
  assert(memo-for != none, message: "memo-for is required")
  assert(memo-from != none, message: "memo-from is required")
  assert(
    memo-style in ("usaf", "daf"),
    message: "memo-style must be \"usaf\" or \"daf\"",
  )

  let actual-date = if date == none { datetime.today() } else { date }
  let classification-color = get-classification-level-color(classification-level)

  // Document-wide typography settings (inlined from configure())
  set par(leading: spacing.line, spacing: spacing.line, justify: false)
  set block(above: spacing.line, below: 0em, spacing: 0em)
  set text(font: body-font, size: font-size, fallback: true)

  set page(
    paper: "us-letter",
    // AFH 33-337 §4: "Use 1-inch margins on the left, right and bottom"
    margin: (
      left: spacing.margin,
      right: spacing.margin,
      top: spacing.margin,
      bottom: spacing.margin,
    ),
    header: {
      // AFH 33-337 "Page numbering" §12: "The first page of a memorandum is never numbered.
      // Number the succeeding pages starting with page 2. Place page numbers 0.5-inch from
      // the top of the page, flush with the right margin."
      context if counter(page).get().first() > 1 {
        place(
          dy: +.5in,
          block(
            width: 100%,
            align(right, text(12pt)[#counter(page).display()]),
          ),
        )
      }

      if classification-level != none {
        place(
          top + center,
          dy: 0.375in,
          text(12pt, font: DEFAULT_BODY_FONTS, fill: classification-color)[#strong(classification-level)],
        )
      }
    },
    footer: {
      place(
        bottom + center,
        dy: -.375in,
        text(12pt, font: DEFAULT_BODY_FONTS, fill: classification-color)[#strong(classification-level)],
      )

      if not falsey(footer-tag-line) {
        place(
          bottom + center,
          dy: -0.625in,
          align(center)[
            #text(fill: LETTERHEAD_COLOR, font: "cinzel", size: 15pt)[#footer-tag-line]
          ],
        )
      }
    },
  )

  render-letterhead(
    letterhead-title,
    letterhead-caption,
    letterhead-font,
    letterhead-seal: letterhead-seal,
    letterhead-seal-subtitle: letterhead-seal-subtitle,
  )

  // AFH 33-337 "Date": "Place the date 1 inch from the right edge, 1.75 inches from the top"
  // Since we have a 1-inch top margin, we need (1.75in - margin) vertical space
  v(1.75in - spacing.margin)

  // Measure and cache body line stride once for downstream spacing logic.
  context {
    let one-line = measure(par(spacing: 0pt)[x]).height
    let line-stride = measure(par(spacing: 0pt)[x#linebreak()x]).height - one-line
    let em-size = measure(box(width: 1em)[]).width
    let legacy-scaled = spacing.vertical * (em-size / 12pt)
    LINE_STRIDE.update(line-stride)
    BLANK_LINE_STEP.update(calc.max(line-stride, legacy-scaled))
  }

  metadata((
    subject: subject,
    original-date: actual-date,
    original-from: first-or-value(memo-from),
    body-font: body-font,
    font-size: font-size,
    auto-numbering: auto-numbering,
    memo-style: memo-style,
  ))

  render-date-section(actual-date, memo-style: memo-style)
  render-for-section(memo-for, memo-for-cols)
  render-from-section(memo-from)
  render-subject-section(subject)
  render-references-section(references)

  it
}
