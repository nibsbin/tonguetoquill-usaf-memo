// backmatter.typ: Backmatter rendering for USAF memorandum
//
// This module implements the backmatter (closing section) of a USAF memorandum per
// AFH 33-337 Chapter 14 "The Closing Section". It handles:
// - Signature block placement and formatting
// - Attachments listing
// - Courtesy copy (cc:) distribution
// - Distribution lists

#import "primitives.typ": *

#let backmatter(
  signature-block: none,
  signature-blank-lines: 4,
  attachments: none,
  cc: none,
  distribution: none,
  leading-pagebreak: false,
) = {
  // Render backmatter sections without paragraph numbering
  render-signature-block(signature-block, signature-blank-lines: signature-blank-lines)
  render-backmatter-sections(
    attachments: attachments,
    cc: cc,
    distribution: distribution,
    leading-pagebreak: leading-pagebreak,
  )
}
