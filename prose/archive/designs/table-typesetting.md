# Table Typesetting

**Status:** Archived (Implemented)

## TL;DR

Tables embedded directly in memo body text via the paragraph buffer system, rendered with simple black cell borders consistent with the clean, formal aesthetic of official USAF memorandums.

## When to Use

When adding or modifying table support in the memo body:

- Table appearance → update `render-memo-table()` in `src/primitives.typ`
- Table capture logic → update `show table` rule in `render-body()` in `src/body.typ`
- Table example → update `template/usaf-template.typ`

## How

Tables are integrated into the paragraph buffer system alongside paragraphs:

1. **First pass (capture)** — `show table` intercepts each table in the body content and pushes it into `PAR_BUFFER` as a dictionary with `kind: "table"`, alongside other element items.
2. **Second pass (render)** — Tables flow through the same unified loop as all element kinds. They receive heading prepend (as a standalone bold line above the table) and final-item orphan/widow handling, but skip paragraph numbering.

Tables do **not** count toward `par_count`, so a single paragraph paired with a table still receives no paragraph number per AFH 33-337 §2.

## Visual Style

| Property | Value |
|----------|-------|
| Stroke | 0.5pt black, all cell sides |
| Padding | 0.5em horizontal, 0.4em vertical |
| Font | Inherits 12pt Times New Roman from body |
| Fill | None (white background) |
| Width | Natural / user-specified columns |
| Spacing | One blank line above (standard body spacing) |

The stroke weight and absence of background fills keeps tables visually subordinate to the text body while remaining clearly readable — consistent with the plain, formal style of USAF correspondence.

## Gotchas

- Tables are **not** numbered as paragraphs, regardless of `par_count`
- Tables **do** participate in heading prepend (bold line above) and final-item orphan/widow handling
- `table.header()` rows will repeat across page breaks naturally (standard Typst behavior)
- Styling is applied via `set table(...)` scoped to `render-memo-table()`, so user-supplied `stroke` arguments on individual cells will be overridden by the template default — this is intentional for visual consistency
- Tables that appear **outside** of `#show: mainmatter` content are not affected; only tables inside the main body go through `render-memo-table()`
