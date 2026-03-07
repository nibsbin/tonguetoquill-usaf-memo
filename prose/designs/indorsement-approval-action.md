# Indorsement Approval/Disapproval Action

**Status:** Implemented

## TL;DR

Add an `action` parameter to `indorsement()` that renders "APPROVED / ~~DISAPPROVED~~" (or vice versa) in the indorsement body, matching the paper convention where the chosen option is circled and the unchosen option is struck through.

## Problem

Indorsement memos frequently carry an approval decision. The standard paper workflow is:

1. The memo presents two options: **APPROVED** and **DISAPPROVED**
2. The reviewer circles one and strikes through the other
3. This prevents after-the-fact forgery by making the choice unambiguous

Our `indorsement()` function currently has no way to express this. Users must manually format the approval line, which is error-prone and inconsistent.

## Design

### New Parameters: `show_action` and `action`

Add two optional parameters to the `indorsement()` function:

```typst
#indorsement(
  from: "ORG/SYMBOL",
  to: "ORG/SYMBOL",
  show_action: true,             // <-- new: render the action line
  action: "approved",            // <-- new: the decision
  signature_block: (...),
)[Optional remarks here.]
```

**`show_action`** (bool, default `false`): Whether to render the APPROVED / DISAPPROVED line.

**`action`** (default `none`): The approval decision.

| `show_action` | `action` | Rendered Output |
|---------------|----------|----------------|
| `false` (default) | `none` (default) | No action line rendered |
| `true` | `none` | APPROVED / DISAPPROVED (both plain, no decision yet) |
| (implied `true`) | `"approved"` | **APPROVED** / ~~DISAPPROVED~~ |
| (implied `true`) | `"disapproved"` | ~~APPROVED~~ / **DISAPPROVED** |

Setting `action` to `"approved"` or `"disapproved"` implicitly shows the action line, so `show_action: true` is only needed when displaying the line without a decision.

### Rendering Rules

The action line is rendered as a single line between the MEMORANDUM FOR header and the body text, with one blank line above and below (same spacing rhythm as other header elements).

```
1st Ind, ORG/SYMBOL                                    6 March 2026

MEMORANDUM FOR  ORG/SYMBOL

APPROVED / D̶I̶S̶A̶P̶P̶R̶O̶V̶E̶D̶

1.  Optional remarks or conditions...

                                        FIRST M. LAST, Rank, USAF
                                        Duty Title
```

**Formatting details:**

- The **chosen** action is rendered in bold, uppercase
- The **unchosen** action is rendered with strikethrough, uppercase
- A forward slash ` / ` separates the two options
- The order is always APPROVED first, DISAPPROVED second (matching standard forms)
- The line is flush left, consistent with body text placement

### Why Bold + Strikethrough (Not Circle)

Real paper memos use a circle around the chosen option. In a typeset document:

- Circles around text look awkward and don't translate well to PDF
- Bold vs. strikethrough creates the same unambiguous visual distinction
- This matches how electronic forms handle the same pattern
- A future digital signing layer can lock the choice with cryptographic proof, making the visual anti-forgery convention less critical

### Implementation Sketch

In `indorsement.typ`, after the MEMORANDUM FOR grid and before `render-body(content)`:

```typst
// Show action line if explicitly requested or if an action decision is set
if show_action or action != none {
  render-action-line(action)
}
```

This goes inside the `if format != "informal"` block, after the header grid but before the body. The body content (remarks, conditions, etc.) follows below as normal.

For `format: "informal"`, the action line renders at the top of the indorsement since there is no header.

### What This Does NOT Cover

- **Digital signing workflow** -- the `action` parameter captures the decision in the document. A future digital signing layer would consume this value plus gather metadata (signer identity, timestamp, certificate, IP, browser, etc.). That is a separate concern and a separate design.
- **Custom action labels** -- "CONCUR / NONCONCUR", "APPROVE WITH CONDITIONS", etc. could be added later by accepting a tuple or enum. The initial implementation covers the most common case.
- **Routing/workflow state** -- this is a typesetting template, not a workflow engine. It renders the result of a decision; it does not manage the decision process.

## API Examples

**Approved with remarks:**
```typst
#indorsement(
  from: "374 AW/CC",
  to: "374 MSG/CC",
  action: "approved",
  signature_block: ("JOHN A. DOE, Col, USAF", "Commander"),
)[Approved with the following condition: funding must be identified from within existing squadron budget NLT 1 Oct.]
```

**Disapproved:**
```typst
#indorsement(
  from: "374 AW/CC",
  to: "374 MSG/CC",
  action: "disapproved",
  signature_block: ("JOHN A. DOE, Col, USAF", "Commander"),
)[Request is disapproved due to insufficient justification. Resubmit with updated cost analysis.]
```

**No decision yet (action line shown, both plain):**
```typst
#indorsement(
  from: "ORG/SYMBOL",
  to: "ORG/SYMBOL",
  show_action: true,
  signature_block: ("NAME, Rank, USAF", "Title"),
)[Forwarded for your action.]
```

**Hidden (default, no action line rendered):**
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
| Minimal API surface | Two new parameters with clear separation of concerns |
| Convention over configuration | APPROVED/DISAPPROVED order is fixed, matching standard forms |
| Template renders decisions, doesn't manage them | No workflow state, routing, or signing logic |
| Anti-forgery by formatting | Bold + strikethrough mirrors the paper circle + strikethrough convention |
