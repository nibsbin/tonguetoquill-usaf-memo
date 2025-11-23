# Backmatter Rendering Unification

**Status:** Active
**Related Cascades:** CASCADES.md#CASCADE-2
**Related Designs:** N/A
**Impact:** Eliminate ~40 lines | Unify 3 implementations → 1

## Problem Statement

Backmatter rendering logic is duplicated across multiple files, with three separate implementations of conceptually identical functionality:

1. **utils.typ:277-311** — `render-backmatter-section()` (35 lines) - DEAD CODE
2. **utils.typ:321-327** — `calculate-backmatter-spacing()` (7 lines) - DEAD CODE
3. **primitives.typ:160-195** — `render-backmatter-section()` (36 lines) - ACTIVELY USED
4. **primitives.typ:197-202** — `calculate-backmatter-spacing()` (6 lines) - ACTIVELY USED
5. **indorsement.typ:82-99** — Inline backmatter rendering (18 lines) - PARTIAL REIMPLEMENTATION

This creates multiple sources of truth for the same conceptual operation: rendering a labeled backmatter section with optional numbering, handling page breaks, and adding continuation labels.

## Core Insight

**"Backmatter section rendering is one concept."**

The logic for "render a labeled section with optional numbering, handle page breaks, add continuation labels" is the SAME conceptual operation regardless of whether it's attachments, cc, or distribution.

Currently implemented 3 times with variations; only needs to exist once.

## Current State Analysis

### What's Actually Used

**primitives.typ** contains the canonical implementations:
- `render-backmatter-section()` at lines 160-195
- `calculate-backmatter-spacing()` at lines 197-202
- `render-backmatter-sections()` at lines 204-240 (orchestrator function)

These are used by:
- **backmatter.typ** (imports `primitives.typ: *` and calls `render-backmatter-sections()`)

### What's Dead Code

**utils.typ** contains duplicate implementations that are never imported:
- `render-backmatter-section()` at lines 277-311 (nearly identical to primitives version)
- `calculate-backmatter-spacing()` at lines 321-327 (exactly identical to primitives version)

No file explicitly imports these functions from utils.typ. They exist but are unused.

### What's Reimplemented

**indorsement.typ** lines 82-99 reimplements backmatter rendering inline:
- Manually constructs attachment sections with custom labels
- Manually handles spacing with `calculate-backmatter-spacing()`
- Uses raw `v(spacing.line, weak: false)` instead of proper abstraction
- Duplicates the logic pattern that already exists in `render-backmatter-section()`

## Desired State

### Architecture Principle

Backmatter rendering flows through one abstraction:

```
primitives.typ (single source of truth)
    ↓
    render-backmatter-section() — handles individual sections
    calculate-backmatter-spacing() — handles section spacing
    render-backmatter-sections() — orchestrates multiple sections
    ↓
    used by backmatter.typ, indorsement.typ, etc.
```

### Module Responsibilities

**primitives.typ:**
- Defines ALL backmatter rendering primitives
- Single source of truth for:
  - Section rendering with page break handling
  - Spacing calculations between sections
  - Multi-section orchestration
- No duplication elsewhere

**utils.typ:**
- Does NOT contain backmatter rendering logic
- Contains only general-purpose utilities
- No duplicate implementations of primitives

**indorsement.typ:**
- Uses `render-backmatter-section()` from primitives.typ
- Does not reimplement rendering logic inline
- Calls the abstraction instead of duplicating patterns

**backmatter.typ:**
- Already correct: uses `render-backmatter-sections()` from primitives.typ

## Benefits Achieved

**Eliminated Complexity:**
- ✓ Dead code removed from utils.typ (~42 lines)
- ✓ Inline duplication removed from indorsement.typ (~18 lines)
- ✓ Risk eliminated of fixing bugs in one implementation but not others
- ✓ Confusion removed about which implementation is canonical
- ✓ Mental overhead eliminated: "How do I render backmatter?"

**Improved Clarity:**
- Single, obvious location for all backmatter rendering
- Clear responsibility: primitives own rendering primitives
- Consistent behavior across all uses

**Reduced Maintenance:**
- Backmatter rendering changes happen in one place
- No synchronization needed between duplicate implementations
- Lower cognitive load for developers

## Design Constraints

**Must Preserve:**
- All existing backmatter rendering behaviors
- All existing indorsement attachment/cc rendering
- Exact same output in all cases

**Must Not:**
- Change any rendering output during this refactor
- Modify any function signatures in primitives.typ (they're the canonical ones)
- Break any existing consumers

## Implementation Strategy

### Phase 1: Remove Dead Code from utils.typ

Remove the unused duplicate functions:
1. Delete `render-backmatter-section()` (utils.typ:277-311)
2. Delete `calculate-backmatter-spacing()` (utils.typ:321-327)

Verification: No imports reference these functions, so deletion is safe.

### Phase 2: Refactor indorsement.typ

Replace inline backmatter rendering (lines 82-99) with calls to `render-backmatter-section()`:

Instead of:
```
if not falsey(attachments) {
  calculate-backmatter-spacing(true)
  let attachment_count = attachments.len()
  let section_label = if attachment_count == 1 { "Attachment:" } else { str(attachment_count) + " Attachments:" }
  text()[#section_label]
  linebreak()
  v(spacing.line, weak: false)
  enum(..attachments, numbering: "1.")
}
```

Use:
```
if not falsey(attachments) {
  calculate-backmatter-spacing(true)
  let attachment-count = attachments.len()
  let section-label = if attachment-count == 1 { "Attachment:" } else { str(attachment-count) + " Attachments:" }
  let continuation-label = (
    (if attachment-count == 1 { "Attachment" } else { str(attachment-count) + " Attachments" })
      + " (listed on next page):"
  )
  render-backmatter-section(attachments, section-label, numbering-style: "1.", continuation-label: continuation-label)
}
```

Apply same pattern to cc section.

## Verification Approach

The refactor is correct if:

1. All example documents render identically before/after
2. Indorsement attachments and cc sections render correctly
3. Backmatter sections in main memos render correctly
4. No compilation errors occur
5. Dead code is completely removed from utils.typ

## Related Simplifications

This design builds on:
- **CASCADE #1 (Configuration Single Source of Truth):** Establishes pattern of eliminating duplicates

This design enables:
- Cleaner module boundaries (primitives own primitives, utils own utilities)
- Future refactoring of backmatter logic (only one place to change)

## References

- CASCADES.md#CASCADE-2 - Full analysis of backmatter rendering duplication
- src/primitives.typ - Canonical backmatter rendering primitives
- src/utils.typ - Utilities file with dead code
- src/indorsement.typ - File with inline reimplementation
- src/backmatter.typ - Already correct usage
