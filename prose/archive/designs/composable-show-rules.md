# Composable Show Rule Architecture

**Status:** Archived (Implemented)

## TL;DR

The template uses composable show rules that mirror document structure: frontmatter → mainmatter → backmatter → indorsements. Each section is independent and chainable.

## When to Use

When working with document structure or adding new sections:

- Adding document sections → create a new show rule
- Modifying section rendering → update the relevant show rule
- Passing context → use document metadata, not global state

## How

Chain show rules in document order:

```typst
#show: frontmatter.with(subject: "...", ...)
// body content
#show: mainmatter
// paragraphs
#show: backmatter.with(signature-block: (...), ...)
```

## Gotchas

- **No global state** — pass context through metadata, not `MAIN_MEMO`
- Each show rule has **single responsibility** — one section
- Downstream rules query config via `query(metadata)`

## Principles

| Principle | Meaning |
|-----------|---------|
| Composability | Chain independent show rules |
| No Global State | Use metadata instead |
| Explicit Flow | Top-to-bottom document structure |
| Single Responsibility | One section per rule |
| DRY | Reusable primitives for signatures, backmatter |

## Module Responsibilities

- **frontmatter.typ** — letterhead, date, FOR, FROM, SUBJECT
- **mainmatter.typ** — paragraph numbering and body content
- **backmatter.typ** — signature, attachments, cc, distribution
- **indorsement.typ** — indorsement headers and content
