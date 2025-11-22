// lib.typ: Public API for USAF memorandum template
//
// This module provides a composable API for creating United States Air Force
// memorandums that comply with AFH 33-337 "The Tongue and Quill" formatting standards.
//
// Key features:
// - Composable show rules for frontmatter and mainmatter
// - Function-based backmatter and indorsements for correct ordering
// - No global state - configuration flows through metadata
// - Reusable primitives for common rendering tasks
// - AFH 33-337 compliant formatting throughout
//
// Basic usage:
//
// #import "@preview/tonguetoquill-usaf-memo:0.2.0": frontmatter, mainmatter, backmatter, indorsement
//
// #show: frontmatter.with(
//   subject: "Your Subject Here",
//   memo_for: ("OFFICE/SYMBOL",),
//   memo_from: ("YOUR/SYMBOL",),
// )
//
// #show: mainmatter
// // Or for rare single-paragraph memos: #show: mainmatter.with(number-paragraphs: false)
//
// Your memo body content here.
//
// #backmatter(
//   signature_block: ("NAME, Rank, USAF", "Title"),
//   attachments: (...),
//   cc: (...),
// )
//
// #indorsement(
//   from: "ORG/SYMBOL",
//   to: "RECIPIENT/SYMBOL",
//   signature_block: ("NAME, Rank, USAF", "Title"),
// )[
//   Indorsement content here.
// ]

#import "frontmatter.typ": frontmatter
#import "mainmatter.typ": mainmatter
#import "backmatter.typ": backmatter
#import "indorsement.typ": indorsement
