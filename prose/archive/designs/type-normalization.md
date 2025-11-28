# Type Normalization Utilities

**Status:** Archived (Implemented)

## TL;DR

Three canonical utility functions handle all type normalization: `ensure-array()`, `ensure-string()`, and `first-or-value()`. Never write inline type checking—use these utilities.

## When to Use

When a function accepts flexible input (string OR array) but needs a canonical form internally:

- Need an array? → `ensure-array(value)`
- Need a string? → `ensure-string(value)`
- Need first element? → `first-or-value(value)`

## How

```typst
// Instead of inline type checking:
if type(recipients) == array {
  recipients = recipients.join("\n")
}

// Use:
let recipients = ensure-string(recipients)
```

## The Functions

| Function | Input | Output |
|----------|-------|--------|
| `ensure-array(value)` | any | array (wraps non-arrays) |
| `ensure-string(value, separator: "\n")` | any | string (joins arrays with separator) |
| `first-or-value(value)` | any | first element or value |

Custom separator example: `ensure-string(items, separator: ", ")`

## Edge Cases

- `ensure-array(none)` → `()`
- `ensure-string(none)` → `""`
- `first-or-value(())` → `none`

## Gotchas

- **Never** inline `if type(x) == array` checks—use the utilities
- These are normalization functions, not validators
- Identity for canonical form: `ensure-array(array)` returns unchanged

## Benefits

- Consistent normalization behavior everywhere
- Bug fixes in one place propagate to all call sites
- Business logic stays focused on its purpose
