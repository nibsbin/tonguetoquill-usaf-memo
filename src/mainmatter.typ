// mainmatter.typ: Mainmatter show rule for USAF memorandum

#import "config.typ": *
#import "utils.typ": *
#import "primitives.typ": *

#let mainmatter = it => {
  // Standardize heading rendering: all heading levels become bold inline text
  // prepended to the following paragraph, consistent with AFH 33-337 memo format
  show heading: h => {
    // Use box() to ensure heading is inline and doesn't create a paragraph element
    box[*#h.body.* ]
  }

  render-paragraph-body(it)
}
