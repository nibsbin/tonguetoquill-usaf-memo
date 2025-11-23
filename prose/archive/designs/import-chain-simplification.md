# Import Chain Simplification

**Status:** Active
**Related Cascade:** CASCADE #3 in CASCADES.md
**Priority:** Medium (implement after configuration-single-source.md)
**Risk:** Low

## Problem Statement

High-level modules explicitly import all three foundation modules, creating redundant import chains and false coupling to implementation details.

### Current State

Every high-level module imports the full foundation stack:

```
frontmatter.typ:  #import config, utils, primitives
mainmatter.typ:   #import config, utils, primitives
backmatter.typ:   #import config, utils, primitives
indorsement.typ:  #import config, utils, primitives
```

**Total:** 15 import statements across 4 high-level modules (4 modules × 3 imports each).

Meanwhile, the foundation modules already form a dependency chain:

```
primitives.typ → imports config + utils
utils.typ      → imports config
config.typ     → imports nothing
```

## Core Insight

**"Imports are transitive — depend only on your immediate neighbor."**

If `primitives.typ` already imports everything from `config` and `utils`, high-level modules only need `primitives`. The transitive closure provides access to everything needed.

This follows basic layered architecture: each layer depends only on the layer immediately below it.

## Desired State

### High-Level Module Imports

High-level modules import only `primitives.typ`:

```
// frontmatter.typ, mainmatter.typ, backmatter.typ, indorsement.typ
#import "primitives.typ": *
```

**Total:** 4 import statements (4 modules × 1 import each).

### Foundation Module Imports

Foundation modules maintain their current layered structure:

```
primitives.typ: #import "config.typ": *
                #import "utils.typ": *

utils.typ:      #import "config.typ": spacing, paragraph-config, counters, CLASSIFICATION_COLORS

config.typ:     (no imports)
```

## Benefits Achieved

1. **Reduced import statements:** 15 → 4 (73% reduction)
2. **Clear API boundary:** `primitives.typ` becomes the public API surface
3. **Decoupling:** High-level code doesn't know about internal layering
4. **Single dependency:** Each high-level module has 1 dependency, not 3
5. **Simplified mental model:** "Import primitives, get everything you need"

## Architectural Principles

### Layered Architecture

The system has three distinct layers:

```
┌─────────────────────────────────────────┐
│  High-Level Modules                     │
│  (frontmatter, mainmatter, backmatter,  │
│   indorsement)                          │
└─────────────────┬───────────────────────┘
                  │ depends on
                  ▼
┌─────────────────────────────────────────┐
│  Public API Layer                       │
│  (primitives.typ)                       │
└─────────────────┬───────────────────────┘
                  │ depends on
                  ▼
┌─────────────────────────────────────────┐
│  Internal Foundation                    │
│  (utils.typ, config.typ)                │
└─────────────────────────────────────────┘
```

### Re-export Strategy

`primitives.typ` serves as the public API boundary by:
- Importing from foundation modules (config, utils)
- Defining high-level primitives
- Re-exporting everything needed by consumers

Consumers depend on primitives, which internally composes lower-level concerns.

## Dependencies

### Must Complete First

- **configuration-single-source.md** (CASCADE #1)

Reason: CASCADE #1 removes duplicate config definitions from `utils.typ`. After that change, `utils.typ` will properly import config values, making the layered structure cleaner.

### Prerequisite Understanding

This design assumes:
- `primitives.typ` already imports `config` and `utils` (✓ verified)
- High-level modules only use symbols available via `primitives.typ` (needs verification)
- No direct usage of config/utils that bypasses primitives (needs verification)

## Verification Requirements

Before implementation, verify:

1. **Symbol availability:** All symbols used by high-level modules are available via `primitives.typ` (either defined there or imported)
2. **No direct config access:** High-level modules don't access config values that aren't re-exported by primitives
3. **No direct utils access:** High-level modules don't call utils functions that aren't available via primitives

If verification finds missing symbols, `primitives.typ` must re-export them.

## Non-Goals

This design does NOT:
- Change what symbols are available (purely reorganizing imports)
- Modify any function implementations
- Change the internal structure of foundation modules
- Add new abstractions or APIs

## Related Designs

- [Configuration Single Source of Truth](./configuration-single-source.md) - Must complete first
- [Backmatter Rendering Unification](./backmatter-rendering-unification.md) - Independent, can be done in any order

## Implementation Complexity

**Estimated complexity:** Low

Changes are mechanical:
1. Verify symbol availability (analysis)
2. Update 4 import statements (simple edits)
3. Verify compilation and tests (validation)

No algorithmic changes, no new code, purely simplification.
