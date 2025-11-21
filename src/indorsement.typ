// indorsement.typ: Indorsement rendering for USAF memorandum

#import "config.typ": *
#import "utils.typ": *
#import "primitives.typ": *

#let indorsement(
  from: none,
  to: none,
  signature_block: none,
  signature_blank_lines: 3,
  attachments: none,
  cc: none,
  same_page: true,
  date: none,
  content
) = {
  assert(from != none, message: "from is required")
  assert(to != none, message: "to is required")
  assert(signature_block != none, message: "signature_block is required")

  let actual_date = if date == none { datetime.today() } else { date }
  let ind_from = if type(from) == array { from.at(0) } else { from }
  let ind_for = to

  context {
    let config = query(metadata).last().value
    let original_subject = config.subject
    let original_date = config.original_date
    let original_from = config.original_from

    counters.indorsement.step()
    let indorsement_number = counters.indorsement.get().first()
    let indorsement_label = format-indorsement-number(indorsement_number)

    if not same_page {
      pagebreak()
      [#indorsement_label to #original_from, #display-date(original_date), #original_subject]

      blank-line()
      grid(
        columns: (auto, 1fr),
        ind_from, align(right)[#display-date(actual_date)],
      )

      blank-line()
      grid(
        columns: (auto, auto, 1fr),
        "MEMORANDUM FOR", "  ", ind_for,
      )
    } else {
      blank-line()
      grid(
        columns: (auto, 1fr),
        [#indorsement_label, #ind_from], align(right)[#display-date(actual_date)],
      )

      blank-line()
      grid(
        columns: (auto, auto, 1fr),
        "MEMORANDUM FOR", "  ", ind_for,
      )
    }
  }

  render-paragraph-body(content)

  render-signature-block(signature_block, signature-blank-lines: signature_blank_lines)

  if not falsey(attachments) {
    calculate-backmatter-spacing(true)
    let attachment_count = attachments.len()
    let section_label = if attachment_count == 1 { "Attachment:" } else { str(attachment_count) + " Attachments:" }

    [#section_label]
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
