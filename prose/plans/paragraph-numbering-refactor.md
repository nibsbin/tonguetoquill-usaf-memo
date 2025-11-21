# Paragraph Numbering Refactor

## Problem

Current implementation uses hacky spacing calculations and recursive logic to achieve hierarchical paragraph numbering:

**Current approach (lib.typ:234-326, utils.typ:368-490):**
- Intercepts `enum.item` and `list.item` to track nesting level via state
- Uses `SET_LEVEL()` state updates to communicate level to paragraph renderer
- Recursively calculates indentation by measuring parent numbers (utils.typ:429-443)
- Manually manages spacing with `h(.25em)` workarounds (utils.typ:486-487)
- Renders content twice to count paragraphs (lib.typ:289-297, 320-323)
- Uses separate counters per level (`par-counter-0`, `par-counter-1`, etc.)

**Issues:**
- **Fragile spacing**: Recursive `calculate-paragraph-indent()` measures parent numbers and adds manual spacing buffers
- **Complex state management**: Multiple interacting states (`PAR_LEVEL_STATE`, `enum-level`, `par-counter`, `total-par-counter`)
- **Hacky workarounds**: Comment admits "Potential bug with spacing; use h(.25em) as an extra spacer" (utils.typ:486). A bug also occurs when a nested paragraph is used before the parent level is initialized.

## Goal

Refactor to use Typst's native numbering system for cleaner, more robust paragraph numbering.

## Possible Approach

- Explore Typst's `numbering()` function and pattern system
- Investigate `show par` rules that can track nesting via enum/list context
- Consider enum.item's built-in counter access instead of manual state
- Integrate cleanly into `mainmatter` from new architecture
- Validate against existing PDF outputs to ensure visual parity

## Requirements
- Number unmarked top-level paragraphs by default
- Process bullet and numbered lists for paragraph nesting
- Maintain visual parity with current output (compare with `pdfs/`)
- Work within the new architecture from ARCHITECTURE_ISSUE.md
- Comply with AFH 33-337 paragraph standards

### AFH 33-337

Must comply with AFH 33-337 official memorandum standards:

**Spacing (AFH 33-337):**
- Single-space text within paragraphs
- Double-space between paragraphs/subparagraphs (one blank line)
- May double-space text of one-paragraph memo less than 8 lines

**Numbering (AFH 33-337):**
- Number and letter each paragraph and subparagraph
- Single paragraph is NOT numbered
- Numbering patterns:
  - Level 0: `1.`, `2.`, `3.`
  - Level 1: `a.`, `b.`, `c.`
  - Level 2: `(1)`, `(2)`, `(3)`
  - Level 3: `(a)`, `(b)`, `(c)`
  - Level 4+: underlined format

**Indentation (AFH 33-337):**
- First paragraph: never indented, numbered and flush left
- Sub-paragraph first line: indent to align number/letter with first **character** of parent paragraph text (not parent number)
- Subsequent lines: all second and subsequent lines flush with left margin (no indent)

![visual reference](visual_reference.png)