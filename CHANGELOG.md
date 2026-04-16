# Changelog

All notable changes to `tonguetoquill-usaf-memo` are documented here.

---

## Unreleased

### Removed

- **`auto_numbering` frontmatter parameter.** Base-level paragraphs are never numbered automatically. Hierarchical AFH-style numbering applies only to explicit `#list` / `#enum` items (same as the former `auto_numbering: false` behavior). Remove `auto_numbering: ...` from `frontmatter.with(...)` calls.

---

## [2.0.0] — 2026-03-11

### Added

- **Indorsement approval/disapproval action line.** New `action` parameter on `indorsement()` renders a formal "Approve / Disapprove" line matching the paper convention where the chosen option is circled.
  - `none` (default) — no action line rendered
  - `"undecided"` — both options shown, neither boxed nor struck through
  - `"approve"` — Approve boxed, Disapprove struck through
  - `"disapprove"` — Disapprove boxed, Approve struck through
- **Inline table formatting.** Tables placed inside `#mainmatter[...]` with `#table(...)` are automatically styled with 0.5 pt black cell borders, standard inset, and bold column headers, consistent with the plain formal aesthetic of USAF correspondence. Tables do not count toward AFH 33-337 §2 paragraph numbering.
- **`auto_numbering` frontmatter parameter.** Set `auto_numbering: false` to suppress base-level paragraph numbering. Explicitly bulleted or enumerated sub-items still receive hierarchical numbering with their level shifted by one.
- **Orphan/widow control for final paragraphs.** The last body paragraph before the signature block is measured; short content (fewer than four lines) is made sticky to prevent it from being orphaned on a preceding page.
- **Action line sticky to signature block.** The action line in indorsements is now kept on the same page as the body content and signature block, preventing it from appearing alone on a trailing page.

### Changed

- **`action` parameter default changed from `"none"` (string) to `none` (Typst keyword).** Callers that passed `action: "none"` explicitly should remove the parameter or pass `action: none`.
- **Paragraph body rendering refactored to a two-pass system.** The first pass collects all paragraphs, list items, headings, and tables into a `PAR_BUFFER` state; the second pass renders them with proper numbering, indentation, and orphan control. This eliminates nested-context counter propagation bugs and makes multi-block list items reliable.
- **Multi-block list items.** Subsequent paragraphs within the same list or enum item are now rendered as continuation blocks — indented to align with the item text but without a new number — rather than being treated as new numbered items.
- **Child counter reset on base-level paragraph.** When `auto_numbering: false` and a base-level paragraph is encountered, all child-level counters are reset so the next sub-item list restarts at `a.` / `(1)` as expected.
- **Heading rendering.** Headings inside `mainmatter` are prepended as inline bold text to the following paragraph rather than rendered as standalone block elements, matching AFH 33-337 style.
- **`mainmatter` changed from show rule with body parameter to a content-block function.** Usage is now `#mainmatter[...]` instead of `#show: mainmatter` followed by bare content. The show-rule form `#show: mainmatter` remains supported for backward compatibility.
- **`auto_numbering` renamed from `number_all_paragraphs`** for cleaner developer experience. The old name is no longer supported.

### Fixed

- Fixed paragraph collection for content wrapped in `strong`, `emph`, `underline`, and `raw` show rules — these no longer swallow paragraphs silently.
- Fixed vertical alignment of the boxed action text in approve/disapprove lines.
- Fixed numbering counter propagation when deeply nested items are followed by shallower items.
- Fixed body spacing bleeding into letterhead vertical spacing.
- Fixed `separate_page` indorsement format (previously `separate-page`).

---

## [1.0.0] — 2025-11-22

Initial stable release.

### Features at 1.0.0

- Composable show-rule architecture: `frontmatter` → `mainmatter` → `backmatter` → `indorsement`
- AFH 33-337 §2 hierarchical paragraph numbering (1., a., (1), (a))
- Automatic letterhead with configurable title, caption, and seal image
- Date, MEMORANDUM FOR, FROM, SUBJECT, and References sections
- Classification-level header/footer banners with DoD standard colors
- Custom footer tagline support (e.g., "semper supra" for Space Force)
- Backmatter: signature block (4.5 in from left, orphan prevention), attachments, cc, distribution with smart page-break continuation labels
- Indorsements: auto-numbered (1st Ind, 2d Ind, …), standard, informal, and separate-page formats
- ISO date string support (`"YYYY-MM-DD"`) for `date` parameters
- `font_size` parameter for font-size control per AFH 33-337 §5 (10 pt minimum)
- Font fallback so NimbusRomNo9L approximates Times New Roman on systems without the proprietary font
