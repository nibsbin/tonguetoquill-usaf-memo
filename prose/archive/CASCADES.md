# Simplification Cascades

**Status:** Archived
**Analysis Date:** 2025-11-22

## TL;DR

Six simplification opportunities identified; four implemented. Each cascade recognizes "these are all the same thing" and eliminates duplicates.

## Cascade Summary

| # | Name | Status | Design/Notes |
|---|------|--------|--------------|
| 1 | Configuration Duplication | ✅ Implemented | [configuration-single-source.md](./designs/configuration-single-source.md) |
| 2 | Backmatter Rendering | ✅ Implemented | [backmatter-rendering-unification.md](./designs/backmatter-rendering-unification.md) |
| 3 | Import Chain Proliferation | ✅ Implemented | [import-chain-simplification.md](./designs/import-chain-simplification.md) |
| 4 | Type Normalization | ✅ Implemented | [type-normalization.md](./designs/type-normalization.md) |
| 5 | State Management Sprawl | ⏸️ Deferred | Not pursuing—overengineered |
| 6 | Vertical Spacing | ⏸️ Deferred | Largely complete; incremental |

## Impact Achieved

- **~175 lines** eliminated
- **17+ concepts** collapsed to **6 abstractions**
- Zero functionality changes

## Core Principle

> "Everything is a special case of [the general pattern]" collapses complexity dramatically.

Each implemented cascade recognized that what appeared to be multiple things was actually one thing:

- Multiple config definitions → One source of truth
- Multiple backmatter renderers → One rendering concept
- Multiple import chains → One dependency layer
- Multiple normalization patterns → One transformation type

## Smaller Opportunities

Documented as inline comments in source code:

- **§A: Date Handling** — Monitor for future Typst improvements (utils.typ)
- **§B: Ordinal Suffix** — Nice-to-have table-driven alternative (utils.typ)
- **§C: Paragraph Detection** — Heuristic fragility documented (primitives.typ)

## References

- Individual designs in `./designs/` subdirectory
- AFH 33-337 Chapter 14 for formatting standards
