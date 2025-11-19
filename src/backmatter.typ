// backmatter.typ: Backmatter show rule for USAF memorandum

#import "config.typ": *
#import "utils.typ": *
#import "primitives.typ": *

#let backmatter(
  signature-block: none,
  signature-blank-lines: 4,
  attachments: none,
  cc: none,
  distribution: none,
  leading-pagebreak: false,
) = {
  assert(signature-block != none, message: "signature-block is required")

  it => {
    render-signature-block(signature-block, signature-blank-lines: signature-blank-lines)

    render-backmatter-sections(
      attachments: attachments,
      cc: cc,
      distribution: distribution,
      leading-pagebreak: leading-pagebreak,
    )

    it
  }
}
