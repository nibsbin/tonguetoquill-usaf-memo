# DAF Memo Style

**Status:** Implemented

## TL;DR

Add a `memo_style` enum to `frontmatter()` with values `"usaf"` and `"daf"`. The default `"usaf"` preserves current behavior. `"daf"` changes paragraph rendering to:

- Top-level body paragraphs are unnumbered and first-line indented by `0.5in`
- First nested paragraph level starts at level 2 formatting (`"a."`, `"b."`, ...)
- Each deeper nested level increases indentation by another `0.5in`

## Problem

The template currently implements AFH 33-337-centric paragraph handling where top-level paragraphs are numbered (`1.`, `2.`, ...), and nested indentation is computed from measured ancestor label widths.

For DAF memo style, paragraph behavior differs:

1. Do not automatically number top-level paragraphs
2. Indent the first line of each top-level paragraph by `0.5in`
3. Start the first nested paragraph at the alpha level (`a.`, `b.`, `c.`)
4. Increase nesting indentation by fixed `0.5in` increments

## Design

### API Surface

`frontmatter()` now accepts:

```typst
memo_style: "usaf" // or "daf"
```

Validation is strict:

```typst
assert(memo_style in ("usaf", "daf"), message: "memo_style must be \"usaf\" or \"daf\"")
```

The value is stored in document metadata and consumed by body renderers:

- `mainmatter()` reads metadata and forwards `memo_style` to `render-body()`
- `indorsement()` reads metadata and forwards `memo_style` to `render-body()`

### Rendering Rules by Style

| Behavior | `"usaf"` | `"daf"` |
|----------|----------|---------|
| Top-level paragraph numbering | Enabled by existing `auto_numbering` logic | Disabled |
| Top-level paragraph indent | Flush left | First-line indent `0.5in` |
| First nested numbered level | Existing hierarchy (`a.` after top-level) | Starts at `a.` |
| Nested indentation basis | Measured width of ancestor labels | Fixed `0.5in` per nesting depth |

For `"daf"`, `auto_numbering` is ignored for body paragraph decisions because style rules fully define numbering/indent behavior.

### DAF Body Mechanics

`render-body()` adds style-aware branch logic:

- Top-level (`nest_level == 0`): render `[ #h(0.5in)#body ]` (no number)
- Nested (`nest_level > 0`): render numbered paragraph using format index = `nest_level`
  - `nest_level = 1` -> `"a."`
  - `nest_level = 2` -> `"(1)"`
  - `nest_level = 3` -> `"(a)"`
- Continuations: align text after current level label width, with fixed base indent
- Counter resets: on any top-level paragraph, reset nested counters so later nested sequences restart predictably

### Configuration Placement

No duplicate constants are introduced outside `config.typ`; DAF-specific behavior is implemented as rendering logic in `body.typ`, keeping static config centralized and behavior localized to the body formatter.

## Backward Compatibility

- Existing documents are unchanged (`memo_style` defaults to `"usaf"`)
- Existing `auto_numbering: false` behavior remains for `"usaf"`
- Indorsements inherit memo style via existing metadata flow

## Example

```typst
#show: frontmatter.with(
  memo_style: "daf",
  subject: "DAF Memo Example",
  memo_for: ("ORG/SYMBOL",),
  memo_from: ("ORG/SYMBOL",),
)

#show: mainmatter

Top-level paragraph text (indented 0.5in, unnumbered).

+ First nested item (renders as a.)
+ Second nested item (renders as b.)
```
