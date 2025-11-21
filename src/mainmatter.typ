// mainmatter.typ: Mainmatter show rule for USAF memorandum

#import "config.typ": *
#import "utils.typ": *
#import "primitives.typ": *

#let mainmatter = it => {
  // Standardize heading rendering: all heading levels become bold inline text
  // prepended to the following paragraph, consistent with AFH 33-337 memo format
  show heading: h => {
    [*#h.body.* ]
  }

  render-paragraph-body(it)
}
