# Plan: CASCADE #2 Backmatter Rendering Unification

**Status:** Active
**Related Design:** [Backmatter Rendering Unification](../designs/backmatter-rendering-unification.md)
**Related Cascade:** CASCADES.md#CASCADE-2
**Priority:** High
**Risk:** Low

## Objective

Eliminate duplicate backmatter rendering implementations by:
1. Removing dead code from utils.typ (~42 lines)
2. Refactoring indorsement.typ to use primitives.typ functions (~18 lines)
3. Establishing primitives.typ as single source of truth for backmatter rendering

**Total elimination:** ~60 lines of duplicate code

## Current State Assessment

### Dead Code in utils.typ
- `render-backmatter-section()` at lines 277-311 (never imported, unused)
- `calculate-backmatter-spacing()` at lines 321-327 (never imported, unused)

### Canonical Implementation in primitives.typ
- `render-backmatter-section()` at lines 160-195 (actively used)
- `calculate-backmatter-spacing()` at lines 197-202 (actively used)
- `render-backmatter-sections()` at lines 204-240 (orchestrator)

### Inline Duplication in indorsement.typ
- Lines 82-99: Manual backmatter rendering for attachments and cc
- Should use `render-backmatter-section()` instead

## Implementation Steps

### Step 1: Remove Dead Code from utils.typ

**Action:** Delete unused duplicate functions

**Files Modified:**
- src/utils.typ

**Changes:**
1. Delete `render-backmatter-section()` function (lines 277-311, ~35 lines)
2. Delete `calculate-backmatter-spacing()` function (lines 321-327, ~7 lines)

**Verification:**
- No explicit imports of these functions exist (verified via grep)
- backmatter.typ uses primitives.typ versions via `#import "primitives.typ": *`
- Deletion is safe

**Lines Eliminated:** ~42

### Step 2: Refactor indorsement.typ Attachments Section

**Action:** Replace inline rendering with `render-backmatter-section()` call

**Files Modified:**
- src/indorsement.typ

**Current Code (lines 82-91):**
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

**New Code:**
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

**Benefits:**
- Uses canonical abstraction
- Gains automatic page break handling with continuation labels
- Consistent behavior with main backmatter rendering

**Lines Eliminated:** ~3 (slight increase in code for better functionality)

### Step 3: Refactor indorsement.typ cc Section

**Action:** Replace inline rendering with `render-backmatter-section()` call

**Files Modified:**
- src/indorsement.typ

**Current Code (lines 93-99):**
```
if not falsey(cc) {
  calculate-backmatter-spacing(falsey(attachments))
  text()[cc:]
  linebreak()
  v(spacing.line, weak: false)
  cc.join("\n")
}
```

**New Code:**
```
if not falsey(cc) {
  calculate-backmatter-spacing(falsey(attachments))
  render-backmatter-section(cc, "cc:")
}
```

**Benefits:**
- Uses canonical abstraction
- Gains automatic page break handling
- Simpler, cleaner code

**Lines Eliminated:** ~3

### Step 4: Verification

**Action:** Verify compilation and output correctness

**Tests:**
1. Compile all example files without errors
2. Verify indorsement examples render correctly:
   - Attachments section appears properly
   - cc section appears properly
   - Spacing is correct
3. Verify main memo examples still work (backmatter.typ unchanged)
4. Check that no imports reference deleted utils.typ functions

**Success Criteria:**
- All examples compile
- Output is visually identical (or improved with page break handling)
- No errors or warnings

## Rollback Plan

If issues arise:
1. Git revert the commit
2. Investigate specific failure
3. Fix and re-apply

Risk is low because:
- Dead code deletion cannot break anything (it's not used)
- indorsement.typ changes use existing, tested primitives
- backmatter.typ is unchanged

## Post-Implementation

### Documentation Updates
- Update prose/designs/INDEX.md (already done)
- Mark this plan as completed (move to prose/plans/completed/)

### Future Opportunities
- Consider whether other files have inline backmatter patterns
- Monitor for consistent usage of primitives.typ functions

## Success Metrics

**Before:**
- 3 implementations of backmatter rendering
- ~60 lines of duplicate code
- Confusion about canonical implementation

**After:**
- 1 implementation in primitives.typ
- ~60 lines eliminated
- Clear single source of truth
- Consistent behavior across all uses

## References

- ../designs/backmatter-rendering-unification.md - Design document
- CASCADES.md#CASCADE-2 - Original cascade analysis
- src/primitives.typ - Canonical implementation
- src/utils.typ - File with dead code to remove
- src/indorsement.typ - File to refactor
