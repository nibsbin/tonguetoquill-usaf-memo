#import "/src/body.typ": *
#import "/src/config.typ": *
#import "/src/utils.typ": *

#set page(height: auto, width: 6.5in, margin: 1in)
#set par(leading: spacing.line, spacing: spacing.line, justify: false)
#set block(above: spacing.line, below: 0em, spacing: 0em)
#set text(font: DEFAULT_BODY_FONTS, size: 12pt)

#let debug-body(content) = {
  let PAR_BUFFER = state("PAR_BUFFER_DEBUG")
  PAR_BUFFER.update(())
  let NEST_DOWN = counter("NEST_DOWN_DEBUG")
  NEST_DOWN.update(0)
  let NEST_UP = counter("NEST_UP_DEBUG")
  NEST_UP.update(0)
  let IS_HEADING = state("IS_HEADING_DEBUG")
  IS_HEADING.update(false)
  let ITEM_FIRST_PAR = state("ITEM_FIRST_PAR_DEBUG")
  ITEM_FIRST_PAR.update(false)

  let first_pass = {
    show par: p => context {
      let nest_level = NEST_DOWN.get().at(0) - NEST_UP.get().at(0)
      let is_heading = IS_HEADING.get()
      let is_first_par = ITEM_FIRST_PAR.get()
      let is_continuation = nest_level > 0 and not is_first_par

      PAR_BUFFER.update(pars => {
        pars.push((
          content: text([#p.body]),
          nest_level: nest_level,
          kind: if is_heading { "heading" } else if is_continuation { "continuation" } else { "par" },
        ))
        pars
      })

      if nest_level > 0 and is_first_par {
        ITEM_FIRST_PAR.update(false)
      }
      p
    }
    show table: t => context {
      PAR_BUFFER.update(pars => {
        pars.push((content: t, nest_level: -1, kind: "table"))
        pars
      })
      t
    }
    {
      show heading: h => {
        IS_HEADING.update(true)
        [#parbreak()#h.body#parbreak()]
        IS_HEADING.update(false)
      }
      show enum.item: it => {
        NEST_DOWN.step()
        ITEM_FIRST_PAR.update(true)
        [#parbreak()#it.body#parbreak()]
        NEST_UP.step()
      }
      show list.item: it => {
        NEST_DOWN.step()
        ITEM_FIRST_PAR.update(true)
        [#parbreak()#it.body#parbreak()]
        NEST_UP.step()
      }
      {
        show strong: it => [#it#sym.zws]
        show emph: it => [#it#sym.zws]
        show underline: it => [#it#sym.zws]
        show raw: it => [#it#sym.zws]
        [#content#parbreak()]
      }
    }
  }
  place(hide(first_pass))

  // Dump the buffer
  context {
    let items = PAR_BUFFER.get()
    [*PAR_BUFFER dump (#items.len() items):*]
    linebreak()
    for (idx, item) in items.enumerate() {
      [#(idx + 1). kind=#item.kind, nest_level=#item.nest_level, content="#item.content"]
      linebreak()
    }
  }
}

= Test: PAR_BUFFER dump

#debug-body[
Write your paragraphs here.

- Use bullets to nest paragraphs.
  - This should be nest_level 2.
    - This should be nest_level 3.
    - Another at nest_level 3.
  - Another at nest_level 2.
- Another at nest_level 1.

Second paragraph.
]
