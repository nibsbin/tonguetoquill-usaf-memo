// mainmatter.typ: Mainmatter show rule for USAF memorandum

#import "config.typ": *
#import "utils.typ": *
#import "primitives.typ": *

/// Mainmatter show rule for USAF memorandum body content.
///
/// Applies AFH 33-337 paragraph numbering and formatting to the main body
/// of the memorandum. Automatically detects single vs. multiple paragraphs
/// to comply with AFH 33-337 numbering requirements.
///
/// - content (content): The body content to render
/// -> content
#let mainmatter(it) = {
  render-paragraph-body(it)
}
