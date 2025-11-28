# Backmatter Rendering Unification

**Status:** Archived (Implemented)

## TL;DR

Backmatter section rendering (attachments, cc, distribution) is one concept with one implementation in `primitives.typ`. All consumers use the canonical functions—never reimplement inline.

## When to Use

When rendering any backmatter section:

- Attachments list
- CC recipients
- Distribution lists
- Any labeled section with page break handling

## How

Use the canonical primitives from `primitives.typ`:

- `render-backmatter-section()` — renders individual sections
- `calculate-backmatter-spacing()` — handles section spacing
- `render-backmatter-sections()` — orchestrates multiple sections

## Gotchas

- **Never** inline backmatter rendering logic—use the primitives
- `utils.typ` should NOT contain backmatter rendering (general utilities only)
- All backmatter changes happen in `primitives.typ`

## Module Responsibilities

| Module | Role |
|--------|------|
| `primitives.typ` | Owns all backmatter rendering |
| `backmatter.typ` | Calls primitives |
| `indorsement.typ` | Calls primitives |
| `utils.typ` | No backmatter code |

## Benefits

- Single location for backmatter logic changes
- Bug fixes propagate automatically
- Consistent behavior across memo types
