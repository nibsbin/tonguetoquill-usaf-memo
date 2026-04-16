// mainmatter.typ: Mainmatter show rule for USAF memorandum
//
// This module implements the mainmatter (body text) of a USAF memorandum per
// AFH 33-337 Chapter 14 "The Text of the Official Memorandum" (§1-12).

#import "body.typ": *

/// Mainmatter show rule for USAF memorandum body content.
///
/// AFH 33-337 "The Text of the Official Memorandum" §1-12 requirements:
/// - Begin text on second line below subject/references
/// - Single-space text, double-space between paragraphs
/// - Base-level paragraphs are flush left and unnumbered
/// - Explicit list/enum items receive hierarchical AFH-style numbering
///
/// - content (content): The body content to render
/// -> content
#let mainmatter(it) = render-body(it)
