# Composable Show Rules Implementation Plan

**Design Reference:** [Composable Show Rule Architecture](../designs/composable-show-rules.md)

## Current State

- Monolithic `official-memorandum()` function in `src/lib.typ`
- Global `MAIN_MEMO` state accessed by indorsements
- Indorsements duplicate signature/backmatter rendering
- All config passed upfront in single function call
- Body and indorsements defined in different locations

## Desired State

- Four composable show rules: `frontmatter`, `mainmatter`, `backmatter`, `indorsement`
- No global state (use metadata query pattern)
- Reusable primitives for signatures, backmatter, paragraph processing
- Config distributed across appropriate show rules
- Natural top-to-bottom document flow

## Implementation Steps

### 1. Module Reorganization

**Create new module structure:**
- `src/lib.typ` - Public API exports
- `src/primitives.typ` - Reusable rendering functions
- `src/frontmatter.typ` - Frontmatter show rule
- `src/mainmatter.typ` - Mainmatter show rule
- `src/backmatter.typ` - Backmatter show rule
- `src/indorsement.typ` - Indorsement show rule
- `src/config.typ` - Constants and configuration
- `src/utils.typ` - Keep existing utilities

### 2. Extract Reusable Primitives

**Move to `src/primitives.typ`:**
- `render-signature-block(lines, blank-lines)` - from lib.typ:206
- `render-backmatter-section(content, label, numbering, continuation)` - from utils.typ:315
- `calculate-backmatter-spacing(is-first)` - from utils.typ:359
- `render-paragraph-body(content)` - extracted from lib.typ:234

**Move to `src/config.typ`:**
- `spacing` constants - from utils.typ:28
- `DEFAULT_LETTERHEAD_FONTS` - from lib.typ:31
- `DEFAULT_BODY_FONTS` - from lib.typ:36
- `LETTERHEAD_COLOR` - from lib.typ:40
- `paragraph-config` - from utils.typ:91
- `counters` - from utils.typ:103

### 3. Implement Frontmatter Show Rule

**In `src/frontmatter.typ`:**
- Accept all letterhead, header, and styling config
- Set page layout with margins, headers, footers
- Render letterhead with seal placement
- Render date, memo-for, memo-from, subject, references sections
- Store config in metadata for downstream rules
- Apply `configure()` typography settings
- Return content unmodified

### 4. Implement Mainmatter Show Rule

**In `src/mainmatter.typ`:**
- Query frontmatter metadata for config
- Apply paragraph numbering show rules
- Process enum/list → AFH 33-337 paragraph conversion
- Use `render-paragraph-body()` primitive
- Return processed content

### 5. Implement Backmatter Show Rule

**In `src/backmatter.typ`:**
- Accept signature-block and backmatter config
- Use `render-signature-block()` primitive
- Use `render-backmatter-section()` for attachments/cc/distribution
- Handle smart page breaks via `leading-pagebreak`
- Return content unmodified

### 6. Implement Indorsement Show Rule

**In `src/indorsement.typ`:**
- Query metadata for original memo subject/date/from
- Auto-increment indorsement counter
- Render indorsement header (1st Ind, 2nd Ind, etc.)
- Render from/for with proper format (same-page vs new-page)
- Use `render-paragraph-body()` for indorsement body
- Use `render-signature-block()` for indorsement signature
- Use `render-backmatter-section()` for indorsement attachments/cc
- Return content unmodified

### 7. Update Public API

**In `src/lib.typ`:**
- Remove `official-memorandum()` function
- Remove `MAIN_MEMO` state
- Remove `indorsement()` data structure
- Export: `frontmatter`, `mainmatter`, `backmatter`, `indorsement`
- Keep utility exports if needed

### 8. Update Templates

**Update all template files:**
- Convert from monolithic `official-memorandum()` to composable API
- Verify layout matches existing PDFs
- Test with various config combinations

## Technical Details

### Metadata Pattern

```typst
// Frontmatter stores config
#metadata((
  subject: "...",
  original-date: datetime.today(),
  original-from: "...",
  body-font: ("times new roman",),
  font-size: 12pt,
))

// Downstream rules query
context {
  let config = query(metadata).last().value
  // Use config...
}
```

### Show Rule Structure

```typst
#let my-section(config-params) = {
  it => context {
    // 1. Query metadata if needed
    // 2. Render section
    // 3. Pass through content
    it
  }
}
```

### Indorsement Counter

Move from data structure with `.render()` method to pure show rule:
- Use document-wide `counter("indorsement")`
- Auto-increment on each `#show: indorsement.with(...)`
- Query counter in context for header numbering

## Validation

- Layout must match existing `pdfs/` output
- All template examples must compile
- No global state (`MAIN_MEMO` removed)
- Each show rule is independently understandable
- Config flows naturally through document structure

## Out of Scope

- Backwards compatibility (explicitly not required)
- API versioning
- Migration tooling
- Documentation updates (separate task)
