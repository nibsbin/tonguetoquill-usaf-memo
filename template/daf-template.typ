// Local import: `memo_style` is not yet in the published package; swap to @preview after release.
#import "/src/lib.typ": backmatter, frontmatter, mainmatter

#show: frontmatter.with(
  letterhead_title: "DEPARTMENT OF THE AIR FORCE",
  letterhead_caption: "123RD OPERATIONS SQUADRON",
  letterhead_seal: image("assets/dow_seal.png"),
  subject: "DAF Memorandum Paragraph Style Example",
  memo_for: "123 OG/CC",
  memo_from: (
    "123 OS/CC",
    "123rd Operations Squadron",
    "Any Base AFB ST 12345",
  ),
  memo_style: "daf",
)

#mainmatter[
  This top-level paragraph demonstrates DAF memo style behavior. It is not automatically numbered, and the first line is indented by one-half inch from the left margin.

  This second top-level paragraph is also unnumbered with the same first-line indentation. Nested content below starts at the alpha level.

  + First nested paragraph at DAF level 2 style. It renders with an alpha marker (`a.`, `b.`, `c.`) and an additional half-inch nested indent.

  + Second nested paragraph at the same level. This body intentionally wraps onto additional lines to show alignment behavior after the numbered marker at this nesting depth.

    + Deeper nested paragraph example. This level increases indentation by another half inch and advances to the next numbering format.

    + Another deep nested paragraph at the same depth to demonstrate progression and spacing consistency.
]

#backmatter(
  signature_block: (
    "JANE Q. EXAMPLE, Lt Col, USAF",
    "Commander",
  ),
)
