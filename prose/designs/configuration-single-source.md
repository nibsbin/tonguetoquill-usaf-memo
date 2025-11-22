# Configuration Single Source of Truth

**Status:** Active
**Related Cascades:** CASCADES.md#CASCADE-1
**Related Designs:** N/A
**Impact:** Eliminate ~60 lines | Unify 4 constants → 1 source

## Problem Statement

Configuration constants are duplicated across multiple files, creating two sources of truth for the same values. Specifically, four configuration constants are defined identically in BOTH `config.typ` AND `utils.typ`:

| Constant | config.typ | utils.typ | Status |
|----------|------------|-----------|--------|
| `spacing` | Lines 11-16 | Lines 28-33 | Exact duplicate |
| `paragraph-config` | Lines 34-40 | Lines 91-95 | Exact duplicate |
| `counters` | Lines 46-48 | Lines 103-105 | Exact duplicate |
| `CLASSIFICATION_COLORS` | Lines 59-64 | Lines 207-212 | Exact duplicate |

This violates the Single Source of Truth principle and creates maintenance risks.

## Core Insight

**"Configuration has one source of truth."**

The file `config.typ` exists precisely to centralize configuration. Yet `utils.typ` re-declares every constant, creating two sources of truth for the same values.

## Desired State

### Architecture Principle

Configuration flows in one direction:

```
config.typ (source of truth)
    ↓
    imported by utils.typ
    ↓
    utils.typ references (not redefines) config values
    ↓
    used by utility functions
```

### Module Responsibilities

**config.typ:**
- Defines ALL configuration constants
- No dependencies (pure constants)
- Single source of truth for:
  - Spacing constants
  - Paragraph numbering configuration
  - Document counters
  - Classification colors
  - Typography defaults

**utils.typ:**
- Imports configuration from config.typ
- References imported config values
- Defines utility functions that USE config (not define it)
- No configuration redefinition

### Import Pattern

utils.typ imports what it needs from config.typ:

```
#import "config.typ": spacing, paragraph-config, counters, CLASSIFICATION_COLORS
```

All utility functions continue working identically - they reference the imported values instead of local duplicates.

## Benefits Achieved

**Eliminated Complexity:**
- ✓ All duplicate definitions removed from utils.typ (~60 lines)
- ✓ Mental overhead eliminated: "Which definition is canonical?"
- ✓ Drift risk removed (can't update one location while forgetting the other)
- ✓ False impression removed that utils.typ "configures" anything

**Improved Clarity:**
- Single, obvious location for all configuration
- Clear dependency direction (config → utils → rest of codebase)
- Module responsibilities clearly separated

**Reduced Maintenance:**
- Configuration changes happen in one place
- No synchronization needed between files
- Lower cognitive load for developers

## Design Constraints

**Must Preserve:**
- All existing utility function behaviors
- All existing configuration values
- All existing APIs (functions that reference config work identically)

**Must Not:**
- Change any configuration values during this refactor
- Modify any function behavior
- Break any existing consumers of utils.typ

## Verification Approach

The refactor is correct if:

1. All utility functions in utils.typ that reference the four constants continue to work identically
2. No behavioral changes occur in any part of the system
3. Configuration values are only defined in config.typ
4. utils.typ imports and references (not redefines) these values

## Related Simplifications

This design enables future cascade simplifications:

- **CASCADE #3 (Import Chain Proliferation):** Once utils.typ properly imports from config.typ, the import chain becomes clearer for high-level modules
- Establishes pattern for other modules to follow (import from config, don't redefine)

## References

- CASCADES.md#CASCADE-1 - Full analysis of configuration duplication
- src/config.typ - Configuration source file
- src/utils.typ - Utility functions file
