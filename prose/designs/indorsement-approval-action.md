# Indorsement Approval/Disapproval Action

**Status:** Implemented

## TL;DR

Add an `action` parameter to `indorsement()` that renders "Approve / Disapprove" in the indorsement body, with the chosen option boxed (circled), matching the paper convention where the chosen option is circled.

## Problem

Indorsement memos frequently carry an approval decision. The standard paper workflow is:

1. The memo presents two options: **Approve** and **Disapprove**
2. The reviewer circles one
3. This prevents after-the-fact forgery by making the choice unambiguous

Our `indorsement()` function supports this via the `action` parameter.

## Design

### The `action` Parameter

A single optional parameter controls both visibility and selection:

```typst
#indorsement(
  from: "ORG/SYMBOL",
  to: "ORG/SYMBOL",
  action: "approve",            // <-- "none", "approve", or "disapprove"
  signature_block: (...),
)[Optional remarks here.]
```

**`action`** (default `"none"`): The approval decision.

| `action` | Rendered Output |
|----------|----------------|
| `"none"` (default) | No action line rendered |
| `"undecided"` | Approve / Disapprove (neither boxed) |
| `"approve"` | [Approve] / Disapprove (Approve boxed) |
| `"disapprove"` | Approve / [Disapprove] (Disapprove boxed) |

The action line is **only displayed** when `action` is set to `"undecided"`, `"approve"`, or `"disapprove"`. When `action` is `"none"` (the default), no action line appears at all.

### Rendering Rules

The action line is rendered as a single line between the MEMORANDUM FOR header and the body text, with one blank line above and below (same spacing rhythm as other header elements).

```
1st Ind, ORG/SYMBOL                                    6 March 2026

MEMORANDUM FOR  ORG/SYMBOL

[Approve] / Disapprove

1.  Optional remarks or conditions...

                                        FIRST M. LAST, Rank, USAF
                                        Duty Title
```

**Formatting details:**

- The **chosen** action is rendered with a box (rounded rectangle) around it
- The **unchosen** action is rendered plain
- A forward slash ` / ` separates the two options
- The order is always Approve first, Disapprove second (matching standard forms)
- The line is flush left, consistent with body text placement
- Present tense wording ("Approve" / "Disapprove") is used

### Why Box (Not Bold + Strikethrough)

Real paper memos use a circle around the chosen option. In a typeset document:

- A box with rounded corners approximates the hand-drawn circle
- This creates an unambiguous visual distinction matching the paper convention
- A future digital signing layer can lock the choice with cryptographic proof

### Implementation

In `indorsement.typ`, after the MEMORANDUM FOR grid and before `render-body(content)`:

```typst
// Show action line only when an action decision is set (not "none")
if action != "none" {
  render-action-line(action)
}
```

In `primitives.typ`, the `render-action-line` function:

```typst
#let render-action-line(action) = {
  assert(
    action in ("none", "approve", "disapprove"),
    message: "action must be \"none\", \"approve\", or \"disapprove\"",
  )
  blank-line()
  let approve-text = if action == "approve" { 
    box(stroke: 0.5pt + black, radius: 2pt, inset: 2pt)[Approve] 
  } else { 
    [Approve] 
  }
  let disapprove-text = if action == "disapprove" { 
    box(stroke: 0.5pt + black, radius: 2pt, inset: 2pt)[Disapprove] 
  } else { 
    [Disapprove] 
  }
  [#approve-text / #disapprove-text]
}
```

### What This Does NOT Cover

- **Digital signing workflow** -- the `action` parameter captures the decision in the document. A future digital signing layer would consume this value plus gather metadata (signer identity, timestamp, certificate, IP, browser, etc.). That is a separate concern and a separate design.
- **Custom action labels** -- "Concur / Nonconcur", "Approve with conditions", etc. could be added later by accepting a tuple or enum. The initial implementation covers the most common case.
- **Routing/workflow state** -- this is a typesetting template, not a workflow engine. It renders the result of a decision; it does not manage the decision process.

## API Examples

**Approved with remarks:**
```typst
#indorsement(
  from: "374 AW/CC",
  to: "374 MSG/CC",
  action: "approve",
  signature_block: ("JOHN A. DOE, Col, USAF", "Commander"),
)[Approved with the following condition: funding must be identified from within existing squadron budget NLT 1 Oct.]
```

**Disapproved:**
```typst
#indorsement(
  from: "374 AW/CC",
  to: "374 MSG/CC",
  action: "disapprove",
  signature_block: ("JOHN A. DOE, Col, USAF", "Commander"),
)[Request is disapproved due to insufficient justification. Resubmit with updated cost analysis.]
```

**Undecided (action line rendered, neither option boxed):**
```typst
#indorsement(
  from: "374 AW/CC",
  to: "374 MSG/CC",
  action: "undecided",
  signature_block: ("JOHN A. DOE, Col, USAF", "Commander"),
)[Forwarding for your decision.]
```

**No action (default, no action line rendered):**
```typst
#indorsement(
  from: "ORG/SYMBOL",
  to: "ORG/SYMBOL",
  signature_block: ("NAME, Rank, USAF", "Title"),
)[Forwarded for your information.]
```

## Extension Points

**Custom action pairs (future):** Accept a dictionary for non-standard action labels:

```typst
action: (chosen: "CONCUR", unchosen: "NONCONCUR")
```

**Digital signing integration (future):** A signing layer would:
1. Read the `action` value from document metadata
2. Prompt the signer to confirm the choice
3. Embed a cryptographic signature with metadata (identity, timestamp, certificate, IP, etc.)
4. Mark the document as signed/locked

This is out of scope for the typesetting template but the `action` parameter provides the data hook.

## Principles

| Principle | Application |
|-----------|-------------|
| Minimal API surface | Single parameter controls both visibility and selection |
| Convention over configuration | Approve/Disapprove order is fixed, matching standard forms |
| Template renders decisions, doesn't manage them | No workflow state, routing, or signing logic |
| Anti-forgery by formatting | Box mirrors the paper circle convention |
