// lib.typ: Public API for USAF memorandum template
//
// This module provides a composable show rule API for creating United States Air Force
// memorandums that comply with AFH 33-337 "The Tongue and Quill" formatting standards.
//
// Key features:
// - Composable show rules for frontmatter, mainmatter, backmatter, and indorsements
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
//   memo-for: ("OFFICE/SYMBOL",),
//   memo-from: ("YOUR/SYMBOL",),
// )
//
// #show: mainmatter
//
// Your memo body content here.
//
// #show: backmatter.with(
//   signature-block: ("NAME, Rank, USAF", "Title"),
// )
//
// #show: indorsement.with(
//   from: "ORG/SYMBOL",
//   to: "RECIPIENT/SYMBOL",
//   signature-block: ("NAME, Rank, USAF", "Title"),
// )
//
// Indorsement content here.

#import "frontmatter.typ": frontmatter
#import "mainmatter.typ": mainmatter
#import "backmatter.typ": backmatter
#import "indorsement.typ": indorsement
