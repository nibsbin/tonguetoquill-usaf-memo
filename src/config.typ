// config.typ: Configuration constants and defaults for USAF memorandum template

// =============================================================================
// SPACING CONSTANTS
// =============================================================================

#let spacing = (
  line: .5em,
  line-height: .7em,
  tab: 0.5in,
  margin: 1in
)

// =============================================================================
// TYPOGRAPHY DEFAULTS
// =============================================================================

#let DEFAULT_LETTERHEAD_FONTS = ("Copperplate CC",)
#let DEFAULT_BODY_FONTS = ("times new roman", "NimbusRomNo9L")
#let LETTERHEAD_COLOR = rgb("#000099")

// =============================================================================
// PARAGRAPH CONFIGURATION
// =============================================================================

#let paragraph-config = (
  counter-prefix: "par-counter-",
  numbering-formats: ("1.", "a.", "(1)", "(a)", n => underline(str(n)), n => underline(str(n))),
  block-indent-state: state("BLOCK_INDENT", true),
)

// =============================================================================
// COUNTERS
// =============================================================================

#let counters = (
  indorsement: counter("indorsement"),
)

// =============================================================================
// CLASSIFICATION COLORS
// =============================================================================

#let CLASSIFICATION_COLORS = (
  "UNCLASSIFIED": rgb(0, 122, 51),
  "CONFIDENTIAL": rgb(0, 51, 160),
  "SECRET": rgb(200, 16, 46),
  "TOP SECRET": rgb(255, 103, 31),
)
