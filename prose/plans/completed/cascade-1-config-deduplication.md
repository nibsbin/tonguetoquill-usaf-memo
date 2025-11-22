# Implementation Plan: CASCADE #1 Configuration Deduplication

**Design:** [Configuration Single Source of Truth](../designs/configuration-single-source.md)
**Cascade Reference:** CASCADES.md#CASCADE-1
**Priority:** Highest (zero risk, highest leverage)
**Risk Level:** Zero

## Current State

Four configuration constants are defined in BOTH `config.typ` AND `utils.typ`:

1. `spacing` (config.typ:11-16, utils.typ:28-33)
2. `paragraph-config` (config.typ:34-40, utils.typ:91-95)
3. `counters` (config.typ:46-48, utils.typ:103-105)
4. `CLASSIFICATION_COLORS` (config.typ:59-64, utils.typ:207-212)

Total duplicate code: ~60 lines across 4 constants.

## Target State

`utils.typ` imports configuration from `config.typ` instead of redefining it. All utility functions reference imported values. Zero duplication.

## Implementation Steps

### Step 1: Add Import Statement to utils.typ

**Location:** Top of utils.typ (after file header comment, before first constant)

**Action:** Add import statement for the four duplicated constants

**Notes:**
- Insert after line 14 (end of header comment block)
- Before line 15 (start of configuration constants section)
- Import exactly the four constants being deduplicated

### Step 2: Remove Duplicate `spacing` Definition

**Location:** utils.typ:28-33

**Action:** Delete the entire `spacing` constant definition (6 lines)

**Verification:** Functions using `spacing` (configure, blank-lines, create-auto-grid) continue to work with imported value

### Step 3: Remove Duplicate `paragraph-config` Definition

**Location:** utils.typ:91-95

**Action:** Delete the entire `paragraph-config` constant definition (5 lines including comments)

**Verification:** Functions using `paragraph-config` (get-paragraph-numbering-format, generate-paragraph-number, calculate-paragraph-indent, memo-par) continue to work with imported value

### Step 4: Remove Duplicate `counters` Definition

**Location:** utils.typ:103-105

**Action:** Delete the entire `counters` constant definition (3 lines including comments)

**Verification:** Functions using `counters` (process-indorsements and any function accessing counters.indorsement) continue to work with imported value

### Step 5: Remove Duplicate `CLASSIFICATION_COLORS` Definition

**Location:** utils.typ:207-212

**Action:** Delete the entire `CLASSIFICATION_COLORS` constant definition (6 lines)

**Verification:** Function `get-classification-level-color` continues to work with imported value

### Step 6: Update Section Comments

**Action:** Update or remove section comments in utils.typ that reference "configuration constants" since utils.typ will no longer define configuration

**Notes:**
- The "CONFIGURATION CONSTANTS" section header (line 15-17) should be updated
- Section should be retitled to reflect that it imports (not defines) configuration

## Testing Strategy

### Compilation Test

Run Typst compilation on all example documents:
- examples/basic-memo.typ
- examples/multi-paragraph.typ
- examples/with-indorsements.typ
- Any other examples in the examples/ directory

All should compile without errors.

### Behavioral Test

Verify that:
1. Spacing values are identical in rendered output
2. Paragraph numbering formats match exactly
3. Classification colors are unchanged
4. Indorsement counters work identically

### Regression Test

Check that no existing functionality breaks:
- Grid layouts render correctly (uses spacing)
- Paragraph numbering increments properly (uses paragraph-config)
- Indorsement numbering works (uses counters)
- Classification markings display correct colors (uses CLASSIFICATION_COLORS)

## Success Criteria

- [ ] utils.typ imports four constants from config.typ
- [ ] All duplicate definitions removed from utils.typ (~60 lines deleted)
- [ ] All example documents compile without errors
- [ ] All utility functions behave identically
- [ ] No changes to rendered output (byte-identical PDFs if possible)
- [ ] config.typ remains unchanged (pure deletion in utils.typ, plus one import)

## Rollback Plan

If issues arise:
1. Revert the import statement
2. Restore the duplicate definitions
3. Return to current state (both files define constants)

Risk is zero because:
- Only changing utils.typ (config.typ untouched)
- Pure refactor (no behavior changes)
- Easy to verify (compilation succeeds or fails)

## Dependencies

**Blocks:** None
**Blocked by:** None
**Enables:** CASCADE #3 (Import Chain Proliferation) - cleaner import patterns

## Implementation Notes

### Import Statement Format

Use explicit imports for clarity:

```
#import "config.typ": spacing, paragraph-config, counters, CLASSIFICATION_COLORS
```

### Line Count Reduction

Expected deletions:
- spacing: 6 lines
- paragraph-config: 5 lines
- counters: 3 lines
- CLASSIFICATION_COLORS: 6 lines
- Section comments: ~40 lines (docstrings explaining each constant)
- **Total: ~60 lines**

### No API Changes

All functions in utils.typ maintain identical signatures and behavior. This is purely internal refactoring.

## Post-Implementation

After successful implementation:
1. Move this plan to `prose/plans/completed/`
2. Update CASCADES.md to mark CASCADE #1 as completed
3. Consider proceeding to CASCADE #6 (Spacing Methods) as next zero-risk simplification

## References

- Design: [Configuration Single Source of Truth](../designs/configuration-single-source.md)
- Analysis: CASCADES.md#CASCADE-1
- Files: src/config.typ, src/utils.typ
