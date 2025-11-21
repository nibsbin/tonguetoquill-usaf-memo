// indorsement.typ: Indorsement show rule for USAF memorandum

#import "config.typ": *
#import "utils.typ": *
#import "primitives.typ": *

#let indorsement(
  from: none,
  to: none,
  signature-block: none,
  signature-blank-lines: 3,
  attachments: none,
  cc: none,
  same-page: true,
  date: none,
) = it => {
  assert(from != none, message: "from is required")
  assert(to != none, message: "to is required")
  assert(signature-block != none, message: "signature-block is required")

  let actual-date = if date == none { datetime.today() } else { date }
  let ind-from = if type(from) == array { from.at(0) } else { from }
  let ind-for = to

  context {
    let config = query(metadata).last().value
    let original-subject = config.subject
    let original-date = config.original-date
    let original-from = config.original-from

    counters.indorsement.step()
    let indorsement-number = counters.indorsement.get().first()
    let indorsement-label = format-indorsement-number(indorsement-number)

    if not same-page {
      pagebreak()
      [#indorsement-label to #original-from, #display-date(original-date), #original-subject]

      blank-line()
      grid(
        columns: (auto, 1fr),
        ind-from, align(right)[#display-date(actual-date)],
      )

      blank-line()
      grid(
        columns: (auto, auto, 1fr),
        "MEMORANDUM FOR", "  ", ind-for,
      )
    } else {
      blank-line()
      grid(
        columns: (auto, 1fr),
        [#indorsement-label, #ind-from], align(right)[#display-date(actual-date)],
      )

      blank-line()
      grid(
        columns: (auto, auto, 1fr),
        "MEMORANDUM FOR", "  ", ind-for,
      )
    }
  }

  render-paragraph-body(it)

  render-signature-block(signature-block, signature-blank-lines: signature-blank-lines)

  if not falsey(attachments) {
    calculate-backmatter-spacing(true)
    let attachment-count = attachments.len()
    let section-label = if attachment-count == 1 { "Attachment:" } else { str(attachment-count) + " Attachments:" }

    [#section-label]
    parbreak()
    enum(..attachments, numbering: "1.")
  }

  if not falsey(cc) {
    calculate-backmatter-spacing(falsey(attachments))
    [cc:]
    parbreak()
    cc.join("\n")
  }
}
