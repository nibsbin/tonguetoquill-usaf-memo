// backmatter.typ: Backmatter rendering for USAF memorandum

#import "config.typ": *
#import "utils.typ": *
#import "primitives.typ": *

#let backmatter(
  signature_block: none,
  signature_blank_lines: 4,
  attachments: none,
  cc: none,
  distribution: none,
  leading_pagebreak: false,
) = {
  assert(signature_block != none, message: "signature_block is required")

  // Set backmatter state to disable paragraph numbering
  IN_BACKMATTER_STATE.update(true)

  // Render backmatter sections without paragraph numbering
  render-signature-block(signature_block, signature-blank-lines: signature_blank_lines)
  render-backmatter-sections(
    attachments: attachments,
    cc: cc,
    distribution: distribution,
    leading-pagebreak: leading_pagebreak,
  )
}
