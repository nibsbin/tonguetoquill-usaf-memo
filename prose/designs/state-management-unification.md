# State Management Unification

**Status:** Active
**Related Cascade:** CASCADE #5 in CASCADES.md
**Dependencies:** None (standalone architectural improvement)
**Risk:** Medium (most invasive refactor)

## Problem Statement

Four independent state objects track rendering context across the codebase:

| State Object | Purpose | Location | Initial Value |
|--------------|---------|----------|---------------|
| `PAR_LEVEL_STATE` | Track paragraph nesting depth | utils.typ:428 | 0 |
| `IN_BACKMATTER_STATE` | Disable paragraph numbering in backmatter | utils.typ:433 | false |
| `paragraph-config.block-indent-state` | Control block indentation | config.typ:39 | true |
| `enum-level` | Track enum nesting (local state) | primitives.typ:263 | 1 |

### Current Pain Points

1. **Scattered state updates**: Updates to related rendering context occur across multiple files
2. **Synchronization risk**: States that should be coordinated are managed independently
3. **Cognitive overhead**: Developers must track 4+ separate state objects mentally
4. **No single source of truth**: "Where am I in document structure?" requires querying multiple states

### Usage Patterns

**PAR_LEVEL_STATE:**
- Updated: utils.typ:444 (`SET_LEVEL`)
- Read: utils.typ:463 (`memo-par`)

**IN_BACKMATTER_STATE:**
- Updated: backmatter.typ:23 (set to true), indorsement.typ:73 (set to false), indorsement.typ:77 (set to true)
- Read: primitives.typ:300 (conditional numbering)

**block-indent-state:**
- Updated: frontmatter.typ:92 (set to false)
- Read: (via paragraph-config structure)

**enum-level:**
- Updated: primitives.typ:271, 280, 285 (increment/decrement during enum/list rendering)
- Read: primitives.typ:272, 286 (`SET_LEVEL`)

## Core Insight

**"These aren't independent concerns — they're facets of rendering context."**

All four states answer the same fundamental question: **"Where am I in the document structure?"**

They represent different dimensions of the same conceptual entity: the current rendering context. They're updated in concert (entering backmatter affects numbering, level affects indentation, etc.).

## Desired State

### Unified Context Structure

A single `RENDER_CONTEXT` state object with structured value containing all rendering context:

```
{
  in-backmatter: false,
  par-level: 0,
  block-indent: true,
  enum-level: 1
}
```

### Design Principles

1. **Single Source of Truth**: One state object contains all rendering context
2. **Atomic Updates**: Related context changes happen together
3. **Clear API Surface**: Well-defined getters/setters for context access
4. **Backward Compatible Behavior**: Rendering output remains identical

### Access Patterns

**Read Operations:**
- Full context: `RENDER_CONTEXT.get()`
- Specific field: `RENDER_CONTEXT.get().par-level`
- Conditional logic: `context { if RENDER_CONTEXT.get().in-backmatter { ... } }`

**Write Operations:**
- Update single field: `RENDER_CONTEXT.update(ctx => (..ctx, par-level: new-level))`
- Update multiple fields: `RENDER_CONTEXT.update(ctx => (..ctx, in-backmatter: true, par-level: 0))`
- Reset to defaults: `RENDER_CONTEXT.update(_ => default-context)`

## Architecture

### State Definition Location

Define `RENDER_CONTEXT` in `config.typ` alongside other global configuration:

- Centralizes all shared state definitions
- Makes rendering context part of document configuration
- Follows existing pattern (paragraph-config already in config.typ)

### Helper Functions Location

Provide convenience functions in `utils.typ`:

- `get-render-context()` → returns full context
- `update-render-context(updater)` → applies update function
- `in-backmatter()` → boolean check for common condition
- Follows existing pattern (utility functions live in utils.typ)

### Migration Strategy

Existing code using old state objects will be updated to use:
- Direct context access: `RENDER_CONTEXT.get().field-name`
- Helper functions: `get-render-context().field-name`
- Convenience checks: `in-backmatter()` instead of `IN_BACKMATTER_STATE.get()`

## Benefits

### Immediate Benefits

1. **Elimination**: Remove 3 separate state declarations
2. **Clarity**: Single lookup point for "where am I?" questions
3. **Safety**: Related states can't drift out of sync
4. **Discoverability**: New developers find all context in one place

### Long-Term Benefits

1. **Extensibility**: Adding new context (e.g., "in-indorsement") requires no new state objects
2. **Debugging**: Context snapshot provides complete rendering state
3. **Testing**: Mock rendering context by setting single object
4. **Patterns**: Establishes precedent for structured state vs. scattered globals

## What This Eliminates

- ✓ 3 separate `state()` declarations
- ✓ Mental overhead: "Which state object do I check?"
- ✓ Risk of states getting out of sync
- ✓ Scattered state updates across codebase
- ✓ False impression that these are independent concerns

## Non-Goals

- **Not changing rendering behavior**: Output must be byte-identical
- **Not restructuring API**: Public functions maintain signatures
- **Not adding features**: Pure refactor, zero new functionality
- **Not optimizing performance**: Focus is on clarity, not speed

## Cross-References

- **Cascade Analysis**: CASCADES.md § CASCADE #5
- **Configuration Design**: prose/designs/configuration-single-source.md
- **Show Rule Architecture**: prose/designs/composable-show-rules.md

## Implementation Considerations

### Migration Order

1. Define unified `RENDER_CONTEXT` alongside old states
2. Add helper functions that bridge old and new
3. Migrate callsites one file at a time
4. Remove old state declarations once unused
5. Clean up helper functions if no longer needed

### Testing Requirements

- Compile tests: Code compiles without errors
- Output tests: Example documents render identically
- Edge cases: Single-paragraph memos, multi-page memos, indorsements
- Regression tests: Known issues don't resurface

### Risk Mitigation

This is the most invasive cascade refactor. Mitigations:

1. **Do last**: Implement after cascades #1-4 are complete and tested
2. **Incremental**: Migrate one file at a time with test between each
3. **Reversible**: Keep old states until migration is complete and verified
4. **Golden files**: Generate PDFs before/after, verify byte-identical

## Success Criteria

- [ ] Single `RENDER_CONTEXT` state defined in config.typ
- [ ] All 4 old state objects removed
- [ ] All callsites migrated to unified context
- [ ] All example documents render identically (PDF byte-comparison)
- [ ] No compilation errors or warnings
- [ ] Code is clearer and more maintainable

## Future Considerations

Once established, this pattern enables:

- **Context snapshots**: Save/restore rendering state for complex layouts
- **Context debugging**: Print full context at any point for troubleshooting
- **Context validation**: Ensure valid state transitions (e.g., can't be in frontmatter AND backmatter)
- **Context extension**: Add new dimensions (in-indorsement, in-signature-block) without proliferating state objects

---

**Design Philosophy**: "Everything is a special case of [the general pattern]" — Four state objects are special cases of "rendering context". Recognizing this eliminates the need for separate objects.
