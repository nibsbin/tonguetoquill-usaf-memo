# Paragraph Numbering System

## Vision

A robust, maintainable paragraph numbering system that uses Typst's native capabilities to deliver AFH 33-337 compliant hierarchical numbering without manual spacing calculations or complex state management.

## Principles

1. **Native First** - Leverage Typst's built-in `numbering()` patterns and counter system
2. **Declarative** - Define numbering format patterns, not imperative rendering logic
3. **Context-Aware** - Use Typst's context system to determine nesting level from document structure
4. **Zero Recursion** - Calculate indentation directly without recursive parent measurements
5. **Single Responsibility** - Paragraph rendering logic lives in one place (mainmatter show rule)

## Architecture

### Numbering Pattern System

AFH 33-337 specifies hierarchical numbering patterns:
- Level 0: `1.`, `2.`, `3.`
- Level 1: `a.`, `b.`, `c.`
- Level 2: `(1)`, `(2)`, `(3)`
- Level 3: `(a)`, `(b)`, `(c)`
- Level 4+: underlined format

These map directly to Typst's numbering patterns: `"1."`, `"a."`, `"(1)"`, `"(a)"`, and custom functions for level 4+.

### Indentation Strategy

Per AFH 33-337:
- Level 0: No indentation (flush left)
- Level 1+: Text aligns with first **character** of parent paragraph text (not parent number)

**Key Insight:** Indentation is a function of parent number width, not recursive calculation.

For a given nesting level N:
- Indentation = sum of widths of all ancestor numbers (0 to N-1) + spacing buffers

This can be calculated directly by measuring the rendered number at each level, eliminating recursion.

### Level Detection

Instead of manually tracking level via state updates, detect nesting context:
- Top-level paragraphs are direct children of mainmatter content
- Nested paragraphs appear within `enum.item` or `list.item` bodies
- Use show rules on `enum.item`/`list.item` to establish nesting context
- Query context depth rather than maintaining explicit state counters

### Counter Management

Use Typst's native counter system:
- One counter per level: `par-counter-0`, `par-counter-1`, etc.
- Counters reset automatically when parent advances
- No manual state synchronization needed

### Integration with Mainmatter

The paragraph numbering system integrates cleanly into the mainmatter show rule from [Composable Show Rules Architecture](./composable-show-rules.md):

```
mainmatter responsibilities:
├── Intercept paragraphs via show par rule
├── Detect nesting level from enum/list context
├── Generate number using level-appropriate pattern
├── Calculate indentation from ancestor number widths
└── Render numbered paragraph with proper spacing
```

## Compliance with AFH 33-337

See [paragraph-numbering-refactor.md](../plans/paragraph-numbering-refactor.md#afh-33-337) for full requirements.

**Spacing:**
- Single-space within paragraphs (via `par(leading: ...)`)
- Double-space between paragraphs (via `blank-line()`)

**Numbering:**
- Multi-paragraph memos are numbered; single paragraphs are not
- Hierarchical patterns follow AFH 33-337 exactly

**Indentation:**
- First paragraph flush left
- Sub-paragraphs indent to align with parent text first character
- Subsequent lines within a paragraph maintain left alignment

## Benefits

- **Maintainability** - No fragile spacing calculations or recursive measurements
- **Correctness** - Built on Typst's proven numbering and context systems
- **Simplicity** - Declarative patterns replace imperative rendering logic
- **Robustness** - No manual state synchronization to get out of sync
- **Performance** - Single-pass rendering without content duplication for counting
