# Composable Show Rule Architecture

## Vision

Transform the USAF memo template from a monolithic state-based approach into a composable show rule system that mirrors the natural document structure: frontmatter → mainmatter → backmatter → indorsements.

## Principles

1. **Composability** - Each section is an independent show rule that can be chained
2. **No Global State** - Eliminate `MAIN_MEMO` and pass context through show rule chain
3. **Explicit Flow** - Document structure flows naturally from top to bottom
4. **Single Responsibility** - Each component renders exactly one document section
5. **DRY** - Reusable primitives for signatures, backmatter sections, etc.

## API Design

### Frontmatter

```typst
#show: frontmatter.with(
  subject: str,
  memo-for: str | array,
  memo-from: str | array,
  date: datetime | str | none,
  references: array | none,

  // Letterhead config
  letterhead-title: str,
  letterhead-caption: str | array,
  letterhead-seal: content | none,
  letterhead-font: str | array,

  // Styling
  body-font: str | array,
  font-size: length,
  memo-for-cols: int,
)
```

**Responsibilities:**
- Set page layout and margins
- Render letterhead with seal
- Render date section
- Render MEMORANDUM FOR section
- Render FROM section
- Render SUBJECT section
- Render references section (if provided)
- Establish typography and spacing rules
- Store configuration in metadata for downstream rules

### Mainmatter

```typst
#show: mainmatter
```

**Responsibilities:**
- Process body content with paragraph numbering
- Handle enum/list conversion to AFH 33-337 format
- Apply proper indentation and spacing
- No parameters needed (inherits from frontmatter)

### Backmatter

```typst
#show: backmatter.with(
  signature-block: array,
  signature-blank-lines: int,
  attachments: array | none,
  cc: array | none,
  distribution: array | none,
  leading-pagebreak: bool,
)
```

**Responsibilities:**
- Render signature block with orphan prevention
- Render attachments section (if provided)
- Render cc section (if provided)
- Render distribution section (if provided)
- Handle smart page breaks

### Indorsement

```typst
#show: indorsement.with(
  from: (str, str),  // (office-symbol, title)
  for: str,          // recipient office symbol
  signature-block: array,
  signature-blank-lines: int,
  attachments: array | none,
  cc: array | none,
  same-page: bool,   // false = new-page indorsement
  date: datetime | str | none,
)
```

**Responsibilities:**
- Render indorsement header (1st Ind, 2nd Ind, etc.)
- Auto-increment indorsement counter
- Render from/for sections
- Process indorsement body
- Render indorsement signature block
- Render indorsement backmatter (attachments, cc)
- Reference original memo subject/date from metadata

## Architecture

### Document Metadata State

Replace global `MAIN_MEMO` with document metadata:

```typst
metadata((
  subject: ...,
  original-date: ...,
  original-from: ...,
  body-font: ...,
  font-size: ...,
  // ... other config
))
```

Downstream show rules query via `query(metadata)` instead of `MAIN_MEMO.get()`.

### Reusable Primitives

Extract shared rendering logic:

- `render-signature-block(lines, blank-lines)`
- `render-backmatter-section(items, label, numbering, continuation)`
- `render-paragraph-body(content)` - paragraph numbering logic

### Show Rule Chain

Each show rule:
1. Queries metadata for configuration
2. Renders its section
3. Passes content through unchanged
4. May update metadata for downstream rules

```typst
#show: rule => {
  // Query config from metadata
  let config = query(metadata).last()

  // Render this section
  render-my-section(config)

  // Pass through remaining content
  rule
}
```

## Migration Path

1. Extract reusable primitives from lib.typ into dedicated modules
2. Implement new show rule functions alongside legacy code
3. Create new template examples using composable API
4. Remove legacy `official-memorandum` and `MAIN_MEMO` state
5. Update documentation

## Benefits

- **Clarity** - Document structure is explicit and readable
- **Flexibility** - Mix and match sections as needed
- **Maintainability** - Each section is independently testable
- **Simplicity** - No global state or action-at-a-distance
- **Alignment** - API mirrors actual document structure
