# Import Chain Simplification

**Status:** Archived (Implemented)

## TL;DR

High-level modules import only `primitives.typ`. Transitive imports provide access to everything from `config.typ` and `utils.typ` automatically.

## When to Use

When adding imports to high-level modules (frontmatter, mainmatter, backmatter, indorsement):

- Import `primitives.typ` only
- Don't directly import `config.typ` or `utils.typ`

## How

Layered architecture with transitive imports:

```
High-Level Modules
    └── imports primitives.typ
            └── imports utils.typ
                    └── imports config.typ
```

High-level: `#import "primitives.typ": *`

## Gotchas

- **Never** import `config.typ` or `utils.typ` directly from high-level modules
- If a symbol isn't available via primitives, add a re-export in `primitives.typ`—don't bypass the layer
- `primitives.typ` is the public API surface

## Benefits

- Single import per high-level module
- Clear API boundary
- High-level code decoupled from internal layering
- "Import primitives, get everything"
