#import "/src/body.typ": render-body
#import "/src/config.typ": *
#import "/src/utils.typ": *

// Minimal document setup for testing body rendering directly
#set page(height: auto, width: 6.5in, margin: 1in)
#set par(leading: spacing.line, spacing: spacing.line, justify: false)
#set block(above: spacing.line, below: 0em, spacing: 0em)
#set text(font: DEFAULT_BODY_FONTS, size: 12pt, fallback: true)

// =====================================================================
// TEST 1: Auto-numbering with multiple top-level paragraphs
// Expected: All paragraphs numbered, starting at correct values,
//           incrementing properly, and resetting child levels.
// =====================================================================
= Test 1: Multi top-level, auto-numbering

#render-body(auto-numbering: true)[
First paragraph.

- Sub A
- Sub B
  - Sub-sub 1
  - Sub-sub 2
    - Deep a
    - Deep b
  - Sub-sub 3
- Sub C

Second paragraph.

- New sub (restart a.)
]

// =====================================================================
// TEST 2: Auto-numbering with single top-level paragraph and sub-items
// Expected: Top-level paragraph NOT numbered per AFH 33-337 §2,
//           sub-items ARE numbered starting at correct values.
// =====================================================================
= Test 2: Single top-level with sub-items

#render-body(auto-numbering: true)[
Only one top-level paragraph.

- Sub A
- Sub B
  - Sub-sub 1
  - Sub-sub 2
]

// =====================================================================
// TEST 3: Auto-numbering with single paragraph, no sub-items
// Expected: Paragraph NOT numbered per AFH 33-337 §2.
// =====================================================================
= Test 3: Single paragraph only

#render-body(auto-numbering: true)[
This is the only paragraph.
]

// =====================================================================
// TEST 4: Auto-numbering disabled (manual mode)
// Expected: Top-level paragraphs not numbered, nested items numbered
//           with level offset -1.
// =====================================================================
= Test 4: Auto-numbering disabled

#render-body(auto-numbering: false)[
First paragraph (no number).

- Group A (1.)
  - Sub A1 (a.)
    - Deep (should be (1))
    - Deep (should be (2))
  - Sub A2 (b.)
- Group B (2.)

Second paragraph (no number, resets).

- New group (restart 1.)
]

// =====================================================================
// TEST 5: Exact problem statement input
// Expected: Single top-level not numbered, nested items numbered
//           correctly: a., (1), (a).
// =====================================================================
= Test 5: Problem statement example

#render-body(auto-numbering: true)[
Write your paragraphs here. Separate them with two new lines.

- Use bullets to nest paragraphs.
  - Second-level nested paragraph.
    - Third-level nested paragraph.
]

// =====================================================================
// TEST 6: Multi-block list items (continuations)
// Expected: First paragraph in list item numbered, subsequent paragraphs
//           in same item are continuations (indented, no number).
// =====================================================================
= Test 6: Multi-block list items

#render-body(auto-numbering: true)[
Opening paragraph.

+ First item, first paragraph.

  First item, continuation paragraph (no number).

+ Second item.

Closing paragraph.
]
