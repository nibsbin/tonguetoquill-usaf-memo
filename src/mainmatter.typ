// mainmatter.typ: Mainmatter show rule for USAF memorandum

#import "config.typ": *
#import "utils.typ": *
#import "primitives.typ": *

/// Mainmatter show rule for USAF memorandum body content.
///
/// Applies AFH 33-337 paragraph numbering and formatting to the main body
/// of the memorandum.
///
/// - number-paragraphs (auto | bool): Controls paragraph numbering behavior.
///   - auto (default): Always number paragraphs (appropriate for 99% of memos)
///   - true: Always number paragraphs
///   - false: Never number paragraphs (for rare single-paragraph memos)
/// - content (content): The body content to render
/// -> content
#let mainmatter(it, number-paragraphs: auto) = {
  render-paragraph-body(it, number-paragraphs: number-paragraphs)
}
