// indorsement.typ — AFH 33-337 Chapter 14 (Indorsements)
// Provides an `Indorsement` constructor and helpers to render same-page indorsements.
// This module expects the caller (e.g., lib.typ) to pass in:
//   - render_closing_section: fn(items, label, numbering_style: none, continuation_label: none)
//   - process_body: fn(content) -> content with memo paragraph processing

#let TWO_SPACES = .5em
#let BLANK_LINE = 1em
#let LINE_SPACING = .5em

// ---- Utilities ----
#let ind_ordinal(n) = {
  // Typst has no % operator; use mod(n, m)
  let last_two = mod(n, 100)
  if last_two == 11 { return str(n) + "th" }
  if last_two == 12 { return str(n) + "th" }
  if last_two == 13 { return str(n) + "th" }
  let last = mod(n, 10)
  if last == 1 { str(n) + "st" }
  else if last == 2 { str(n) + "d" }   // AF style: 2d, 3d
  else if last == 3 { str(n) + "d" }
  else { str(n) + "th" }
}

// ---- Indorsement “constructor” ----
// Usage:
//   let ind = Indorsement.new((memo_for: ("HQ DEMO/CCE"), body: [Text here]))
//   ind.render(1, (from_block: fb, subject: subj), (render_closing_section: rcs, process_body: pb))
#let Indorsement = (
  new: (args) => {
    // normalize optional args with defaults deferred to render-time
    (
      memo_for: if args.memo_for != none { args.memo_for } else { () },
      from_block: args.from_block,   // may be none → falls back to defaults.from_block
      subject: args.subject,         // may be none → falls back to defaults.subject
      date: args.date,               // may be none → defaults to today
      address_label: args.address_label, // default applied in render
      body: args.body,
      attachments: if args.attachments != none { args.attachments } else { () },

      // Method: render this indorsement block
      render: (idx, defaults, deps) => {
        // Validate dependencies
        assert(deps != none, "Indorsement.render requires deps")
        assert(deps.render_closing_section != none, "Missing deps.render_closing_section")
        assert(deps.process_body != none, "Missing deps.process_body")

        let label_ord = ind_ordinal(idx) + " Ind"

        let from_blk = if self.from_block != none { self.from_block } else { defaults.from_block }
        let subj = if self.subject != none { self.subject } else { defaults.subject }
        let memo_for_val = self.memo_for
        let date_val = if self.date != none { self.date } else { datetime.today() }
        let addr_label = if self.address_label != none { self.address_label } else { "MEMORANDUM FOR" }
        let attachments = self.attachments

        let has_route = if type(memo_for_val) == array { memo_for_val.len() > 0 } else { repr(memo_for_val).len() > 0 }
        let org_symbol = if from_blk != none and from_blk.len() > 0 { from_blk.at(0) } else { "" }

        block[
          // top spacing from previous section
          #v(3 * LINE_SPACING)

          // Header line: "1st Ind, ORG/SYMBOL, DD Month YYYY"
          text(12pt, weight: "bold")[#label_ord, #org_symbol, #date_val.display("[day] [month repr:long] [year]")]

          // Routing line (MEMORANDUM FOR / TO / THRU)
          #if has_route {
            v(BLANK_LINE)
            grid(
              columns: (auto, TWO_SPACES, 1fr),
              addr_label + ":", "",
              align(left)[
                #if type(memo_for_val) == array { memo_for_val.join("\n") } else { memo_for_val }
              ]
            )
          }

          // SUBJECT
          v(BLANK_LINE)
          grid(columns: (auto, TWO_SPACES, 1fr), "SUBJECT:", "", [#subj])

          // Body
          v(BLANK_LINE)
          set par(justify: true)
          #if self.body != none { deps.process_body(self.body) }

          // Optional attachments for the indorsement block
          #if attachments.len() > 0 {
            v(2 * LINE_SPACING)
            let num = attachments.len()
            let label = (if num == 1 { "Attachment:" } else { str(num) + " Attachments:" })
            let continuation = (if num == 1 { "Attachment" } else { str(num) + " Attachments" }) + " (listed on next page):"
            deps.render_closing_section(attachments, label, numbering_style: "1.", continuation_label: continuation)
          }
        ]
      },
    )
  }
)

// ---- Normalization helper ----
// Accept a dictionary or an Indorsement record (with a render method)
#let normalize_indorsement(item) = {
  if type(item) == dictionary {
    Indorsement.new(item)
  } else {
    // Assume it's already an Indorsement-like record with .render
    item
  }
}

// ---- Public: render a list of indorsements (same-page only) ----
// list: array<dict | IndorsementRecord>
// defaults: (from_block: ..., subject: ...)
// deps: (render_closing_section: fn, process_body: fn)
#let render-indorsements(list, defaults, deps) = {
  if list.len() == 0 { return [] }
  assert(deps != none, "render_indorsements requires deps")
  for (i, it) in list.enumerate() {
    let inst = normalize_indorsement(it)
    inst.render(i + 1, defaults, deps)
  }
}
