# Paragraph Numbering System

**Status:** Archived (Implemented)

## TL;DR

AFH 33-337 compliant hierarchical paragraph numbering using Typst's native counter and numbering systems. Zero manual spacing calculations or recursive measurements.

## When to Use

When modifying paragraph numbering or indentation:

- Numbering patterns are in mainmatter show rule
- Indentation calculates from ancestor number widths
- Level detection uses enum/list context, not explicit state

## How

Typst's native numbering patterns map to AFH 33-337 levels:

| Level | Pattern | Example |
|-------|---------|---------|
| 0 | `"1."` | 1., 2., 3. |
| 1 | `"a."` | a., b., c. |
| 2 | `"(1)"` | (1), (2), (3) |
| 3 | `"(a)"` | (a), (b), (c) |
| 4+ | underlined | custom function |

## Gotchas

- **Multi-paragraph memos** are numbered; single paragraphs are not
- **Indentation** aligns with parent text first character, not parent number
- **Level detection** uses show rules on `enum.item`/`list.item`, not manual tracking
- **Counter reset** happens automatically when parent advances

## AFH 33-337 Compliance

- Single-space within paragraphs
- Double-space between paragraphs
- First paragraph flush left
- Sub-paragraphs indent to parent text alignment
