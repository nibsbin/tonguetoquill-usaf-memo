# Simplification Cascades Analysis

**Analysis Date:** 2025-11-22
**Codebase:** USAF Memorandum Template (`src/`)
**Methodology:** Simplification Cascades — "Find one insight that eliminates multiple components"

---

**⚠️ ARCHIVED:** This analysis is complete. Cascades #1-4 have been implemented.
- Remaining opportunities (Cascades #5-6 and smaller items) are documented inline in source code
- See git history for implementation PRs
- Archived: 2025-11-23

---

## Executive Summary

This analysis identifies **6 major simplification cascades** where recognizing "these are all the same thing" would eliminate significant complexity:

- **~175 lines of code** could be eliminated
- **17+ duplicate concepts** could collapse into **6 unified abstractions**
- **Zero functionality changes** — pure structural simplification

The core principle: When the same concept is implemented multiple ways, find the unifying insight that makes the duplicates unnecessary.

---

## CASCADE #1: Configuration Duplication ✅ IMPLEMENTED

**Impact:** Eliminate ~60 lines | Unify 4 constants → 1 source
**Risk:** Zero | **Priority:** Highest
**Status:** Completed (see prose/plans/completed/cascade-1-config-deduplication.md)

### The Pattern

Four configuration constants are defined identically in BOTH `config.typ` AND `utils.typ`:

| Constant | config.typ | utils.typ | Status |
|----------|------------|-----------|--------|
| `spacing` | Lines 11-16 | Lines 28-33 | Exact duplicate |
| `paragraph-config` | Lines 34-40 | Lines 91-95 | Exact duplicate |
| `counters` | Lines 46-48 | Lines 103-105 | Exact duplicate |
| `CLASSIFICATION_COLORS` | Lines 59-64 | Lines 207-212 | Exact duplicate |

### The Insight

**"Configuration has one source of truth."**

The file `config.typ` exists precisely to centralize configuration. Yet `utils.typ` re-declares every constant, creating two sources of truth for the same values.

### What This Eliminates

- ✓ All duplicate definitions in `utils.typ`
- ✓ Mental overhead: "Which definition is canonical?"
- ✓ Drift risk when updating one location but forgetting the other
- ✓ False impression that `utils.typ` "configures" anything

### The Fix Concept

**utils.typ** should import and reference config values, not redefine them:

```
// Instead of re-declaring spacing, paragraph-config, etc.
#import "config.typ": spacing, paragraph-config, counters, CLASSIFICATION_COLORS
```

All utility functions continue working — they just reference the imported values instead of local duplicates.

### Verification

Grep for usage of these constants in `utils.typ` — all references work identically whether the constant is locally defined or imported.

---

## CASCADE #2: Backmatter Rendering Duplication ✅ IMPLEMENTED

**Impact:** Eliminate ~40 lines | Unify 3 implementations → 1
**Risk:** Low | **Priority:** High
**Status:** Completed (see prose/plans/completed/cascade-2-backmatter-unification.md)

### The Pattern

Backmatter rendering logic exists in THREE places:

1. **utils.typ:319-353** — `render-backmatter-section()` (47 lines)
2. **primitives.typ:160-195** — `render-backmatter-section()` (36 lines, nearly identical)
3. **indorsement.typ:82-99** — Inline backmatter rendering (18 lines, partial reimplementation)

Additionally, `calculate-backmatter-spacing()` is duplicated:
- **utils.typ:363-369** (identical implementation)
- **primitives.typ:197-202** (identical implementation)

### The Insight

**"Backmatter section rendering is one concept."**

The logic for "render a labeled section with optional numbering, handle page breaks, add continuation labels" is the SAME conceptual operation regardless of whether it's attachments, cc, or distribution.

Currently implemented 3 times; only needs to exist once.

### What This Eliminates

- ✓ Duplicate function implementations in `utils.typ` (appears unused based on actual imports)
- ✓ Inline backmatter logic in `indorsement.typ` attachments/cc handling
- ✓ Risk of fixing bugs in one implementation but not others
- ✓ Confusion about which implementation is canonical

### The Fix Concept

**Keep only primitives.typ versions** (they're what's actually used):

1. Remove `render-backmatter-section()` from `utils.typ`
2. Remove `calculate-backmatter-spacing()` from `utils.typ`
3. Refactor `indorsement.typ:82-99` to call `render-backmatter-sections()` with `attachments` and `cc` parameters instead of reimplementing the logic

The shared abstraction already exists in `primitives.typ:204-240` — it just needs to be used consistently.

### Verification

- `backmatter.typ` imports from `primitives.typ` and uses those implementations
- `utils.typ` versions appear to be dead code (no imports found)
- `indorsement.typ` reimplements the pattern inline rather than reusing the abstraction

---

## CASCADE #3: Import Chain Proliferation ✅ IMPLEMENTED

**Impact:** Reduce import statements from 15 to 5
**Risk:** Low | **Priority:** Medium (do after CASCADE #1)
**Status:** Completed (see prose/plans/completed/implement-import-chain-simplification.md)

### The Pattern

Every high-level module imports ALL THREE foundation modules:

```
frontmatter.typ:  #import config, utils, primitives
mainmatter.typ:   #import config, utils, primitives
backmatter.typ:   #import config, utils, primitives
indorsement.typ:  #import config, utils, primitives
```

Meanwhile, the dependency chain is:
```
primitives.typ → imports config + utils
utils.typ      → imports config
config.typ     → imports nothing (pure constants)
```

**15 total import statements** for what should be **5**.

### The Insight

**"Imports are transitive — depend only on your immediate neighbor."**

If `primitives.typ` already imports everything from `config` and `utils`, then high-level modules only need `primitives`. The transitive closure provides access to everything needed.

This is basic layering: each layer depends only on the layer immediately below it.

### What This Eliminates

- ✓ 10 redundant import statements (each high-level module drops 2 of 3 imports)
- ✓ Cognitive load of tracking "what comes from where?"
- ✓ False coupling to implementation details (consumers shouldn't know about internal layering)
- ✓ The illusion that high-level code has 3 dependencies when it really has 1

### The Fix Concept

**High-level modules import only `primitives.typ`:**

```
// frontmatter.typ, mainmatter.typ, backmatter.typ, indorsement.typ
#import "primitives.typ": *
```

**primitives.typ** becomes the public API surface, re-exporting what it needs from config/utils.

This matches common architectural patterns: consumers depend on the highest-level abstraction, which internally composes lower-level concerns.

### Verification

- Trace what each high-level module actually uses
- Confirm all used symbols are available via `primitives.typ` (either defined there or imported)
- No high-level module should use config/utils directly

---

## CASCADE #4: Type Normalization Boilerplate ✅ IMPLEMENTED

**Impact:** Replace ~30 lines with 2 reusable functions
**Risk:** Very Low | **Priority:** Medium
**Status:** Completed (see prose/plans/completed/cascade-4-type-normalization.md)

### The Pattern

"Normalize input type" logic repeats in 5+ functions:

| Location | Pattern | Lines |
|----------|---------|-------|
| utils.typ:253-266 | `create-auto-grid` | String → Array |
| primitives.typ:18-24 | `render-letterhead` | Font normalization |
| primitives.typ:26-28 | `render-letterhead` | Array → String (join) |
| primitives.typ:95-97 | `render-from-section` | Array → String (join) |
| primitives.typ:329-336 | `render-backmatter-section` | Content normalization |

Each does inline type checking, branching, and conversion:

```
if type(content) == str {
  content = (content,)
}

if type(from_info) == array {
  from_info = from_info.join("\n")
}
```

### The Insight

**"Input normalization is a cross-cutting concern with two canonical forms."**

The pattern is always the same:
1. Accept flexible input (string OR array)
2. Normalize to canonical form (array OR string)
3. Proceed with normalized value

This is textbook abstraction opportunity — the same transformation repeated everywhere.

### What This Eliminates

- ✓ All inline `if type(x) == array { ... } else { ... }` blocks
- ✓ Repeated patterns of `.join("\n")` or `.join(separator)`
- ✓ Repeated patterns of wrapping singles in `(value,)` tuples
- ✓ Mental overhead of "how do I normalize this input again?"

### The Fix Concept

Add to `utils.typ` (or new `normalize.typ`):

```
ensure-array(value) -> array
  // If already array, return as-is
  // If string, wrap in (value,)
  // Handles edge cases (none, empty)

ensure-string(value, separator: "\n") -> string
  // If already string, return as-is
  // If array, join with separator
  // Handles edge cases (none, empty)
```

Replace all normalization sites with these calls:

```
// Before
if type(recipients) == array {
  recipients = recipients.join("\n")
}

// After
recipients = ensure-string(recipients)
```

### Verification

Search codebase for:
- `if type(...) == array`
- `if type(...) == str`
- `.join("\n")`
- `(value,)` wrapping patterns

Each occurrence is a candidate for replacement.

---

## CASCADE #5: State Management Sprawl ❌ NOT PURSUING

**Impact:** Replace 4 state objects with 1 unified context
**Risk:** Medium (most invasive) | **Priority:** Low (do last)
**Status:** Not pursuing - overengineered solution, current approach is clearer

### The Pattern

Four independent state objects track rendering context:

| State Object | Purpose | Location |
|--------------|---------|----------|
| `IN_BACKMATTER_STATE` | Disable paragraph numbering | utils.typ:467 |
| `PAR_LEVEL_STATE` | Track paragraph nesting depth | utils.typ:462 |
| `paragraph-config.block-indent-state` | Control block indentation | config.typ:39, utils.typ:94 |
| `enum-level` | Track enum nesting (local state) | primitives.typ:278 |

### The Insight

**"These aren't independent concerns — they're facets of rendering context."**

All four states answer the question: "Where am I in the document structure?"

They're updated in concert (entering backmatter disables numbering AND affects level tracking). They represent different aspects of the same conceptual entity: **the current rendering context**.

### What This Eliminates

- ✓ Mental overhead of tracking 4+ separate state objects
- ✓ Risk of states getting out of sync with each other
- ✓ Scattered state updates across the codebase
- ✓ The false impression that these are independent when they're conceptually related

### The Fix Concept

Single state object with structured value:

```
render-context = state("render-context", (
  in-backmatter: false,
  par-level: 0,
  block-indent: true,
  enum-level: 1
))
```

All updates go through one entry point. Queries return the full structure or specific fields.

This mirrors common patterns:
- React's context
- Rendering pipelines with pass-through state
- Monadic contexts in functional programming

### Verification

Trace all `.update()` and `.get()` calls on the 4 state objects. Confirm they're updated in correlated ways (e.g., entering backmatter affects multiple states).

### Caution

This is the most invasive refactor. Changes touch many callsites. Do this LAST, after other cascades are resolved and tests are comprehensive.

---

## CASCADE #6: Vertical Spacing Inconsistency ✅ LARGELY COMPLETE

**Impact:** Standardize ~15 spacing calls
**Risk:** Very Low | **Priority:** Medium
**Status:** Largely implemented - abstraction exists and is used consistently in most places

### The Pattern

Multiple ways to create vertical space throughout the codebase:

| Method | Locations | Abstraction Level |
|--------|-----------|-------------------|
| `blank-lines(n)` / `blank-line()` | utils.typ:64-79 | High (abstraction) |
| Raw `v(spacing.line)` | indorsement.typ:89, 97 | Low (raw spacing) |
| `linebreak()` | primitives.typ:169, indorsement.typ:88, 96 | Medium (Typst primitive) |
| `parbreak()` | Various (paragraph detection) | Medium (Typst primitive) |
| Manual calculations | Inside `blank-lines` implementation | Low (raw math) |

### The Insight

**"Vertical spacing should have ONE canonical method."**

The abstraction `blank-lines()` already exists and handles:
- Correct calculation of space based on line height + leading
- Weak vs. strong spacing (page break behavior)
- Consistent spacing units across the document

Yet it's not consistently used. Some code uses raw `v()`, some uses `linebreak()`, some uses the abstraction.

### What This Eliminates

- ✓ All raw `v()` calls throughout the codebase
- ✓ All raw `linebreak()` / `parbreak()` calls (unless they serve distinct semantic purpose)
- ✓ Inconsistent spacing behavior across different modules
- ✓ The mental question: "How do I add space here?"

### The Fix Concept

**Establish convention:** `blank-line()` / `blank-lines(n)` is THE way to add vertical space.

Audit all spacing calls:
- `v(...)` → `blank-lines(...)`
- `linebreak()` → `blank-line()` (if used for spacing)
- Keep `linebreak()` only where it has distinct semantic meaning (e.g., within text lines)

Consider adding `blank-line-break()` wrapper if `linebreak()` serves a purpose distinct from spacing.

### Verification

Search for:
- `v(`
- `linebreak()`
- `parbreak()`

Evaluate each occurrence: spacing (use abstraction) vs. semantic markup (keep as-is).

---

## Smaller Opportunities (Honorable Mentions)

**Note:** These opportunities have been documented as minimal inline comments in the source code for future consideration.

### A. Date Handling Complexity ✅ DOCUMENTED

**Location:** utils.typ:189-204 (`display-date()`)

**Pattern:**
Complex branching for string vs datetime, ISO detection, TOML parsing workaround.

**Observation:**
This may be minimal given Typst's type system constraints. The TOML parsing trick is clever but fragile. Worth monitoring if Typst adds native ISO date parsing.

**Action:** Monitor, not urgent.
**Status:** Inline comment added at utils.typ:154 (see CASCADES.md §A)

---

### B. Ordinal Suffix Logic ✅ DOCUMENTED

**Location:** utils.typ:525-540 (`get-ordinal-suffix()`)

**Pattern:**
Complex modulo arithmetic for "st/d/d/th" suffixes.

**Observation:**
Could be table-driven instead of algorithmic:

```
// Algorithm (current)
if last-two-digits >= 11 and last-two-digits <= 13 { "th" }
else if last-digit == 1 { "st" }
else if last-digit == 2 { "d" }
...

// Table-driven (alternative)
let suffix-map = (11: "th", 12: "th", 13: "th", 1: "st", 2: "d", 3: "d", default: "th")
```

**Action:** Nice-to-have, not urgent. Current implementation is correct and self-contained.
**Status:** Inline comment added at utils.typ:492 (see CASCADES.md §B)

---

### C. Paragraph Detection Heuristic ✅ DOCUMENTED

**Location:** primitives.typ:253-264 (`detect-multiple-paragraphs()`)

**Pattern:**
Uses string parsing of `repr(content)` to detect paragraph breaks:

```
let content-str = repr(content)
let has-double-newline = content-str.contains("\n\n") or content-str.contains("\\n\\n")
let has-parbreak = content-str.contains("parbreak()")
```

**Observation:**
Inherently fragile — depends on internal string representation of content. If Typst changes how `repr()` formats content, this breaks.

**Risk:** Medium. This is a heuristic that might fail on edge cases.

**Action:** Explore if Typst provides structural content introspection (inspect content tree rather than string representation). If not, document the limitation and fragility.
**Status:** Inline comment added at primitives.typ:238 (see CASCADES.md §C)

---

## Red Flags Present

Using the simplification cascades framework's "Red Flags You're Missing a Cascade" checklist:

| Red Flag | Status | Evidence |
|----------|--------|----------|
| "We just need to add one more case..." | ✓ Present | Type normalization pattern repeats in each new function |
| "These are all similar but different" | ✓ Present | 3 backmatter renderers, 4 state objects |
| Refactoring feels like whack-a-mole | ✓ Present | Updating config requires touching multiple files |
| Growing configuration file | ✓ Present | Config values duplicated across files |
| "Don't touch that, it's complicated" | ✓ Present | Paragraph detection heuristic, date parsing |

---

## Cascade Measurement Summary

Using the skill's metric: **"Measure in 'how many things can we delete?'"**

| Cascade | Lines Eliminated | Concepts Unified | Files Touched |
|---------|------------------|------------------|---------------|
| #1 Configuration Duplication | ~60 | 4 constants → 1 source | 1 (utils.typ) |
| #2 Backmatter Rendering | ~40 | 3 implementations → 1 | 2 (utils.typ, indorsement.typ) |
| #3 Import Chain | ~10 imports | 15 imports → 5 | 4 (all high-level modules) |
| #4 Type Normalization | ~30 | 5+ patterns → 2 functions | 2 (utils.typ, primitives.typ) |
| #5 State Management | ~20 | 4 states → 1 context | 3 (config, utils, primitives) |
| #6 Spacing Methods | ~15 | 4 methods → 1 abstraction | 2 (primitives, indorsement) |
| **TOTAL** | **~175 lines** | **17+ → 6 concepts** | **8 files (some overlap)** |

**Expected outcome:** Codebase ~15% smaller, conceptually ~60% simpler (measured by number of distinct patterns).

---

## Implementation Priority

Recommended order (based on risk, dependencies, and leverage):

### Phase 1: Zero-Risk Wins
1. **CASCADE #1** — Configuration Duplication (highest leverage, zero risk)
2. **CASCADE #6** — Spacing Methods (low risk, improves consistency)

### Phase 2: Structural Cleanup
3. **CASCADE #2** — Backmatter Rendering (removes duplication, enables consistency)
4. **CASCADE #4** — Type Normalization (improves readability, low risk)

### Phase 3: Architectural Refactor
5. **CASCADE #3** — Import Chain (best done after #1, clarifies API boundaries)
6. **CASCADE #5** — State Management (highest complexity, most invasive, do last)

**Principle:** Start with deletions (removing duplicates), then abstractions (adding utilities), then restructuring (changing architecture).

---

## Testing Strategy

For each cascade, verify:

1. **Compile tests:** Does the code still compile without errors?
2. **Output tests:** Do example documents render identically before/after?
3. **Edge case tests:** Do single-paragraph memos, multi-page memos, indorsements all work?
4. **Regression tests:** Check known issues don't resurface

**Golden files approach:**
- Generate PDFs from examples before refactor
- Generate PDFs from examples after refactor
- Diff the PDFs (should be byte-identical)

---

## Philosophical Note

These cascades follow the core principle:

> **"Everything is a special case of [the general pattern]" collapses complexity dramatically.**

Each cascade represents a recognition that what appeared to be multiple things is actually one thing:

- Multiple config definitions → One source of truth
- Multiple backmatter renderers → One rendering concept
- Multiple import chains → One dependency layer
- Multiple normalization patterns → One transformation type
- Multiple state objects → One rendering context
- Multiple spacing methods → One spacing abstraction

The insight eliminates the duplicates. The codebase becomes simpler not through cleverness, but through recognition.

---

## References

- **AFH 33-337 Chapter 14:** "The Official Memorandum" (formatting standards)
- **Simplification Cascades Skill:** `.claude/skills/simplification-cascades/SKILL.md`
- **Codebase:** All files in `src/*.typ`

**Analysis completed:** 2025-11-22
**Next action:** Review with maintainers, prioritize implementation phases
