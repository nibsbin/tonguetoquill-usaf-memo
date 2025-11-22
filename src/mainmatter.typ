// mainmatter.typ: Mainmatter show rule for USAF memorandum

#import "config.typ": *
#import "utils.typ": *
#import "primitives.typ": *

#let mainmatter = it => {
  // Store heading data in state for deferred rendering
  let pending-heading = state("pending-heading", none)

  // Standardize heading rendering: all heading levels become bold inline text
  // prepended to the following paragraph, consistent with AFH 33-337 memo format
  show heading: h => {
    pending-heading.update(h.body)
    // Return nothing - heading will be prepended to next paragraph
    none
  }

  // Intercept paragraphs to prepend any pending heading
  show par: p => context {
    let heading-text = pending-heading.get()
    if heading-text != none {
      pending-heading.update(none)
      par[*#heading-text.* #p.body]
    } else {
      p
    }
  }

  render-paragraph-body(it)
}
