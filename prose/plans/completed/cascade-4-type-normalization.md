# Implementation Plan: CASCADE #4 Type Normalization

**Design:** [Type Normalization Utilities](../designs/type-normalization.md)
**Cascade Reference:** CASCADES.md#CASCADE-4
**Priority:** Medium
**Risk Level:** Very Low

## Current State

Input normalization logic repeats across 5+ functions:

| Location | Pattern | Lines |
|----------|---------|-------|
| primitives.typ:18-24 | Font normalization (string/array → array) | 7 |
| primitives.typ:26-28 | Caption normalization (array → string) | 3 |
| primitives.typ:95-97 | From-info normalization (array → string) | 3 |
| primitives.typ:171-174 | Content normalization (string/array → array) | 4 |
| frontmatter.typ:110 | Extract first from (array/string → string) | 1 |
| indorsement.typ:26 | Extract first from (array/string → string) | 1 |

Additional occurrences:
- primitives.typ:82: recipients array check
- primitives.typ:144: signature-lines join
- primitives.typ:175: content join
- utils.typ:155: date type check

Total: ~30 lines of inline normalization boilerplate across 4 files.

## Target State

Three canonical normalization functions in `utils.typ`:

1. **ensure-array(value)** - Normalize to array form
2. **ensure-string(value, separator: "\n")** - Normalize to string form
3. **first-or-value(value)** - Extract first element or return value

All normalization sites use these utilities instead of inline type checking.

## Implementation Steps

### Step 1: Add Normalization Utilities to utils.typ

**Location:** utils.typ, after existing utility functions (around line 250, before paragraph numbering section)

**Action:** Add three normalization utility functions

**Details:**
- `ensure-array(value)`: Returns array; wraps non-arrays in tuple, passes arrays through
- `ensure-string(value, separator: "\n")`: Returns string; joins arrays with separator, passes strings through
- `first-or-value(value)`: Returns first array element or the value itself

**Notes:**
- Handle `none` gracefully (none → empty array/string)
- Handle empty arrays gracefully
- Make functions idempotent (calling multiple times has same effect)

### Step 2: Refactor primitives.typ - render-letterhead

**Location:** primitives.typ:18-28

**Current pattern:**
```
if type(font) != array {
  if type(font) != str {
    font = ()
  } else {
    font = (font,)
  }
}

if type(caption) == array {
  caption = caption.join("\n")
}
```

**Action:** Replace with:
```
font = ensure-array(font)
caption = ensure-string(caption)
```

**Lines eliminated:** ~10 lines of type checking logic

### Step 3: Refactor primitives.typ - render-from-section

**Location:** primitives.typ:95-97

**Current pattern:**
```
if type(from-info) == array {
  from-info = from-info.join("\n")
}
```

**Action:** Replace with:
```
from-info = ensure-string(from-info)
```

**Lines eliminated:** 3 lines

### Step 4: Refactor primitives.typ - render-backmatter-sections

**Location:** primitives.typ:171-174

**Current pattern:**
```
let items = if type(content) == array { content } else { (content,) }
...
if type(content) == array {
  content.join("\n")
```

**Action:** Replace with:
```
let items = ensure-array(content)
...
ensure-string(content)
```

**Lines eliminated:** Simplification of existing lines

### Step 5: Refactor primitives.typ - Additional Occurrences

**Locations:**
- primitives.typ:82 (recipients array check)
- primitives.typ:144 (signature-lines join)
- primitives.typ:175 (content join)

**Action:** Replace inline type checks and joins with appropriate utility calls

### Step 6: Refactor frontmatter.typ

**Location:** frontmatter.typ:110

**Current pattern:**
```
original_from: if type(memo_from) == array { memo_from.at(0) } else { memo_from }
```

**Action:** Replace with:
```
original_from: first-or-value(memo_from)
```

**Lines eliminated:** Ternary operator replaced with function call

### Step 7: Refactor indorsement.typ

**Location:** indorsement.typ:26

**Current pattern:**
```
let ind_from = if type(from) == array { from.at(0) } else { from }
```

**Action:** Replace with:
```
let ind_from = first-or-value(from)
```

**Lines eliminated:** Ternary operator replaced with function call

### Step 8: Refactor utils.typ - Date Handling

**Location:** utils.typ:155

**Current pattern:**
```
if type(date) == str {
  // ... date parsing logic
}
```

**Action:** Consider if `ensure-string()` is appropriate here, or if this is domain logic (not pure normalization)

**Notes:** May not be a candidate for normalization if the type check serves a semantic purpose beyond normalization

## Testing Strategy

### Compilation Test

Run Typst compilation on all example documents:
- examples/basic-memo.typ
- examples/multi-paragraph.typ
- examples/with-indorsements.typ
- Any other examples in the examples/ directory

All should compile without errors.

### Behavioral Tests

For each refactored site, verify:

1. **String input**: Single string values work identically
2. **Array input**: Array values work identically
3. **Mixed input**: Both forms produce correct output
4. **Edge cases**: `none`, empty arrays, empty strings handled gracefully

### Equivalence Tests

Compare rendered output before and after:
- Letterhead with string vs array fonts
- From sections with string vs array values
- Backmatter with string vs array content
- Indorsements with string vs array from values

### Unit Tests (if possible in Typst)

Direct verification of normalization functions:
- `ensure-array("foo")` should behave like `("foo",)`
- `ensure-string(("a", "b"))` should produce `"a\nb"`
- `first-or-value(("x", "y"))` should produce `"x"`

## Success Criteria

- [ ] Three normalization utilities added to utils.typ
- [ ] All inline type normalization in primitives.typ replaced
- [ ] All inline type normalization in frontmatter.typ replaced
- [ ] All inline type normalization in indorsement.typ replaced
- [ ] ~30 lines of boilerplate eliminated
- [ ] All example documents compile without errors
- [ ] All rendered output identical to pre-refactor
- [ ] No API changes (functions still accept string-or-array)

## Rollback Plan

If issues arise:
1. Revert the normalization utility definitions
2. Restore inline type checking at each site
3. Return to current state

Risk is very low because:
- Only internal refactoring (no API changes)
- Each refactored site can be reverted independently
- Easy to verify (compilation + output comparison)
- Type normalization is simple transformation logic

## Dependencies

**Blocks:** None
**Blocked by:** None
**Enables:**
- Future functions can use normalization utilities from day one
- Establishes pattern for handling flexible inputs

## Implementation Notes

### Function Signatures

**ensure-array(value)**
- Parameter: any value
- Returns: array
- Behavior: `(value,)` if not array, else `value`

**ensure-string(value, separator: "\n")**
- Parameters: any value, optional separator string
- Returns: string
- Behavior: `value.join(separator)` if array, else `value`

**first-or-value(value)**
- Parameter: any value
- Returns: any (first element if array, else value)
- Behavior: `value.at(0)` if array, else `value`

### Edge Case Handling

- `none` input should return empty array/string or `none` (consistent behavior)
- Empty arrays should not error
- Single-element arrays work identically to raw values

### Documentation

Add docstring comments to each utility function explaining:
- Purpose (what normalization it performs)
- Input types accepted
- Output type guaranteed
- Edge case behavior

## Post-Implementation

After successful implementation:
1. Move this plan to `prose/plans/completed/`
2. Update CASCADES.md to mark CASCADE #4 as completed
3. Consider proceeding to CASCADE #6 (Spacing Methods) as next low-risk simplification

## Verification Checklist

Before marking complete, verify:

- [ ] `typst compile examples/basic-memo.typ` succeeds
- [ ] `typst compile examples/multi-paragraph.typ` succeeds
- [ ] `typst compile examples/with-indorsements.typ` succeeds
- [ ] Visual inspection: PDFs render identically
- [ ] Grep for `if type(.*) ==` shows only domain logic (not normalization)
- [ ] All `.join("\n")` calls have semantic meaning (not normalization)

## References

- Design: [Type Normalization Utilities](../designs/type-normalization.md)
- Analysis: CASCADES.md#CASCADE-4
- Files: src/utils.typ, src/primitives.typ, src/frontmatter.typ, src/indorsement.typ
