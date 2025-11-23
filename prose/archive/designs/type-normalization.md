# Type Normalization Utilities

**Cascade:** CASCADE #4
**Status:** Active
**Risk Level:** Very Low
**Priority:** Medium

## Problem Statement

Input normalization logic repeats across 5+ functions throughout `primitives.typ`, `utils.typ`, `frontmatter.typ`, and `indorsement.typ`. Each function independently handles type checking and conversion between strings and arrays, creating ~30 lines of duplicate code.

The pattern manifests in two forms:

1. **String-to-Array normalization**: Wrapping single values in tuples
2. **Array-to-String normalization**: Joining arrays with separators

This duplication creates:
- Mental overhead ("How do I normalize this input again?")
- Risk of inconsistent normalization behavior
- Increased maintenance burden (bug fixes must be replicated)
- Code obscurity (normalization logic mixed with business logic)

## Current State

### Pattern 1: Ensure Array

Functions that need arrays perform inline normalization:

**primitives.typ:171-174** (`render-backmatter-sections`)
**primitives.typ:18-24** (`render-letterhead`)

Each location independently implements "if not array, make it array" logic.

### Pattern 2: Ensure String

Functions that need strings perform inline normalization:

**primitives.typ:26-28** (`render-letterhead`)
**primitives.typ:95-97** (`render-from-section`)

Each location independently implements "if array, join it" logic.

### Pattern 3: Extract First Element

Functions that need a single value from string-or-array:

**frontmatter.typ:110** (extracting original_from)
**indorsement.typ:26** (extracting ind_from)

Each location independently implements "if array, take first; else use as-is" logic.

## Desired State

### Canonical Normalization Functions

Two utility functions in `utils.typ` provide canonical normalization:

**ensure-array(value) → array**
- Purpose: Normalize any input to array form
- Behavior: Arrays pass through unchanged, non-arrays wrap in tuple
- Edge cases: `none` → empty array, already-array → identity

**ensure-string(value, separator: "\n") → string**
- Purpose: Normalize any input to string form
- Behavior: Strings pass through unchanged, arrays join with separator
- Edge cases: `none` → empty string, already-string → identity

**first-or-value(value) → any**
- Purpose: Extract first element from array or return value
- Behavior: Arrays return `.at(0)`, non-arrays return as-is
- Edge cases: Empty array → `none`

### Usage Pattern

All normalization sites use these utilities instead of inline type checking:

**Before:**
```
if type(recipients) == array {
  recipients = recipients.join("\n")
}
```

**After:**
```
recipients = ensure-string(recipients)
```

The business logic remains focused on its purpose, delegating type normalization to the canonical functions.

## Benefits

### Conceptual Simplification

"Type normalization is a solved problem with canonical solutions"

Instead of 5+ different implementations of "make this an array" or "make this a string", the codebase has exactly two functions that handle all cases.

### Maintenance Simplification

Bug fixes and enhancements (e.g., handling `none`, custom separators) happen in one location and propagate throughout the codebase.

### Readability Improvement

Business logic becomes clearer when normalization is extracted:
- `let recipients = ensure-string(recipients)` — explicit intent
- `if type(...) == array { ... } else { ... }` — obscures intent

### Consistency Guarantee

All normalization follows identical rules because all normalization uses the same functions.

## Non-Goals

- **Not changing API contracts**: Functions still accept string-or-array inputs
- **Not adding type validation**: These are normalization utilities, not validators
- **Not changing behavior**: The transformations are identical to current inline logic

## Design Principles

### Principle 1: Identity for Canonical Form

If input is already in the target form, return it unchanged (identity function).

This makes the functions safe to call defensively without performance penalty.

### Principle 2: Predictable Edge Cases

Handle `none`, empty arrays, and empty strings consistently:
- `ensure-array(none)` → `()`
- `ensure-string(none)` → `""`
- `first-or-value(())` → `none`

### Principle 3: Single Responsibility

Each function has one job: normalize to a specific type. They don't validate, transform semantically, or handle domain logic.

## Cross-References

- **CASCADE #4 Analysis**: CASCADES.md#CASCADE-4
- **Implementation Plan**: prose/plans/cascade-4-type-normalization.md
- **Related Designs**: None (foundational utility)

## Success Metrics

- **Lines eliminated**: ~30 lines of inline normalization logic removed
- **Concepts unified**: 5+ normalization patterns → 3 canonical functions
- **Files touched**: 4 (utils.typ, primitives.typ, frontmatter.typ, indorsement.typ)
- **API changes**: None (pure internal refactoring)

## Testing Strategy

### Equivalence Testing

For each refactored site, verify that:
1. Single string input produces identical output
2. Array input produces identical output
3. Edge cases (none, empty) produce identical output

### Regression Testing

All example documents render byte-identically before and after refactoring.

### Unit Testing (if feasible)

Direct tests of normalization functions:
- `ensure-array("foo")` → `("foo",)`
- `ensure-string(("a", "b"))` → `"a\nb"`
- `first-or-value(("x", "y"))` → `"x"`

## Open Questions

None. This is a straightforward extraction of existing patterns into utilities.

## References

- AFH 33-337: No direct reference (internal implementation detail)
- Typst Type System: https://typst.app/docs/reference/foundations/type/
- Simplification Cascades: "Replace N implementations with 1 abstraction"
