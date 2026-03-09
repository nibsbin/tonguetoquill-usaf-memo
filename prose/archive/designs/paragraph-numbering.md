# Paragraph Numbering System

**Status:** Archived (Implemented)

## TL;DR

AFH 33-337 compliant hierarchical paragraph numbering using a two-pass system: first pass collects paragraphs with nesting metadata, second pass renders with manual counter tracking and `numbering()` formatting.

## When to Use

When modifying paragraph numbering or indentation:

- Numbering patterns are in `config.typ` (`paragraph-config.numbering-formats`)
- Indentation calculates from ancestor number widths via `calculate-indent-from-counts()`
- Level detection uses show rules on `enum.item`/`list.item` in the first pass
- Counter tracking uses a dictionary (`level-counts`) in the second pass — **not** Typst counters

## How

Typst's `numbering()` function maps AFH 33-337 levels:

| Level | Pattern | Example |
|-------|---------|---------|
| 0 | `"1."` | 1., 2., 3. |
| 1 | `"a."` | a., b., c. |
| 2 | `"(1)"` | (1), (2), (3) |
| 3 | `"(a)"` | (a), (b), (c) |
| 4+ | underlined | custom function |

### Two-pass architecture

1. **First pass** (`show par`, `show table`, `show enum.item`, `show list.item`): Captures elements into `PAR_BUFFER` as dictionaries with `content`, `nest_level`, and `kind` (`"par"`, `"heading"`, `"table"`, or `"continuation"`). Multi-block list items are detected via `ITEM_FIRST_PAR` state — only the first paragraph of each item is numbered; subsequent blocks within the same item are marked as continuations.

2. **Second pass** (single `context` block): Iterates `PAR_BUFFER` with a unified loop that processes all element kinds. Headings are buffered and prepended to the next element (inline for paragraphs, standalone bold line for tables). Numbering is tracked per level using a `level-counts` dictionary, and paragraphs render with `format-numbered-par()` or `format-continuation-par()`. Tables render via `render-memo-table()`. All element kinds flow through final-item orphan/widow handling. Counter values are managed as plain variables — **no nested context blocks** — to avoid Typst's cross-context state propagation limitations.

## Gotchas

- **Multi-paragraph memos** are numbered; single paragraphs are not
- **Multi-block list items**: only the first paragraph gets a number; continuation paragraphs are indented to align with the numbered paragraph's text
- **Indentation** aligns with parent text first character, not parent number
- **Level detection** uses show rules on `enum.item`/`list.item`, not manual tracking
- **Counter reset** happens when a parent level advances (child levels reset to 1)
- **Non-paragraph elements** (tables, etc.) flow through the full rendering pipeline — heading prepend and final-item handling apply to all element kinds, not just paragraphs
- **Do not use nested `context` blocks** for counter/state propagation — counter and state updates made inside one nested `context` block are not visible to subsequent nested `context` blocks within the same layout pass; each nested context resolves against the state snapshot at the outer context's position

## AFH 33-337 Compliance

- Single-space within paragraphs
- Double-space between paragraphs
- First paragraph flush left
- Sub-paragraphs indent to parent text alignment
