// frontmatter.typ: Frontmatter show rule for USAF memorandum

#import "config.typ": *
#import "utils.typ": *
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
  letterhead-font: DEFAULT_LETTERHEAD_FONTS,

  body-font: DEFAULT_BODY_FONTS,
  font-size: 12pt,
  memo-for-cols: 3,

  classification-level: none,
  footer-tag-line: none,
) = {
  assert(subject != none, message: "subject is required")
  assert(memo-for != none, message: "memo-for is required")
  assert(memo-from != none, message: "memo-from is required")

  let actual-date = if date == none { datetime.today() } else { date }
  let classification-color = get-classification-level-color(classification-level)

  it => configure(body-font, font-size: font-size, {
    set page(
      paper: "us-letter",
      margin: (
        left: spacing.margin,
        right: spacing.margin,
        top: spacing.margin,
        bottom: spacing.margin
      ),
      header: context {
        if counter(page).get().first() > 1 {
          place(
            dy: +.5in,
            block(
              width: 100%,
              align(right,
                text(12pt)[#counter(page).display()]
              )
            )
          )
        }

        if classification-level != none {
          place(
            top + center,
            dy: 0.375in,
            text(12pt, font: DEFAULT_BODY_FONTS, fill: classification-color)[#strong(classification-level)]
          )
        }
      },
      footer: context {
        place(
          bottom + center,
          dy: -.375in,
          text(12pt, font: DEFAULT_BODY_FONTS, fill: classification-color)[#strong(classification-level)]
        )

        if not falsey(footer-tag-line) {
          place(
            bottom + center,
            dy: -0.625in,
            align(center)[
              #text(fill: LETTERHEAD_COLOR, font: "cinzel", size: 15pt)[#footer-tag-line]
            ]
          )
        }
      }
    )

    paragraph-config.block-indent-state.update(false)

    render-letterhead(letterhead-title, letterhead-caption, letterhead-seal, letterhead-font)

    v(1.75in - spacing.margin)
    context {
      render-date-section(actual-date)
    }
    render-for-section(memo-for, memo-for-cols)
    render-from-section(memo-from)
    render-subject-section(subject)
    render-references-section(references)

    metadata((
      subject: subject,
      original-date: actual-date,
      original-from: if type(memo-from) == array { memo-from.at(0) } else { memo-from },
      body-font: body-font,
      font-size: font-size,
    ))

    it
  })
}
