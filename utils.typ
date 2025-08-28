// utils.typ: Utility functions and backend code for Typst USAF memo template.

// =============================================================================
// CONFIGURATION CONSTANTS
// =============================================================================

/// Spacing constants following AFH 33-337 standards
#let spacing = (
  two-spaces: 0.5em,      // Standard two-space separator
  line: 0.5em,            // Line spacing within paragraphs
  paragraph: 1em,         // Blank line between paragraphs
  tab: 0.5in,             // Tab stop for alignment
)

/// Paragraph numbering configuration
#let paragraph-config = (
  counter-prefix: "par-counter-",
  numbering-formats: ("1.", "a.", "(1)", "(a)", n => underline(str(n)), n => underline(str(n))),
  block-indent-state: state("BLOCK_INDENT", true),
)

/// Global counters for document structure
#let counters = (
  indorsement: counter("indorsement"),
)

// =============================================================================
// GRID LAYOUT UTILITIES
// =============================================================================

/// Creates an automatic grid layout from 1D or 2D array
/// @param rows: Array of content (1D or 2D)
/// @param column_gutter: Space between columns
/// @returns: Grid with proper formatting
#let create-auto-grid(rows, column-gutter: .5em) = {
  // Normalize input to 2D array for consistent processing
  let normalized-rows = if rows.len() > 0 and type(rows.at(0)) != array {
    rows.map(item => (item,))  // Convert 1D to 2D
  } else {
    rows
  }
  
  // Calculate maximum column count
  let max-columns = calc.max(..normalized-rows.map(row => row.len()))

  // Build cell array in row-major order
  let cells = ()
  for row in normalized-rows {
    for i in range(0, max-columns) {
      let cell-content = if i < row.len() { row.at(i) } else { [] }
      cells.push([#cell-content])
    }
  }

  grid(
    columns: max-columns,
    column-gutter: column-gutter,
    row-gutter: spacing.line,
    ..cells
  )
}

// =============================================================================
// CLOSING SECTION UTILITIES
// =============================================================================

/// Renders closing sections with intelligent page break handling
/// @param content: Section content to render
/// @param section_label: Label for the section (e.g., "Attachments:")
/// @param numbering_style: Optional numbering format for lists
/// @param continuation_label: Label when content continues on next page
/// @returns: Properly formatted section with page break handling
#let render-closing-section(content, section-label, numbering-style: none, continuation-label: none) = {
  let formatted-content = {
    [#section-label]
    parbreak()
    if numbering-style != none { 
      let items = if type(content) == array { content } else { (content,) }
      enum(..items, numbering: numbering-style) 
    } else { 
      if type(content) == array {
        content.join("\n")
      } else {
        content
      }
    }
  }
  
  context {
    let available-space = page.height - here().position().y - 1in
    if measure(formatted-content).height > available-space {
      let continuation-text = if continuation-label != none { 
        continuation-label 
      } else { 
        section-label + " (listed on next page):" 
      }
      continuation-text
      pagebreak()
    }
    formatted-content
  }
}

/// Calculates vertical spacing before closing sections
/// @param is_first_section: Whether this is the first closing section
/// @returns: Appropriate vertical spacing
#let calculate-closing-spacing(is-first-section) = {
  context {
    let space = if is-first-section { 3 * spacing.line } else { 2 * spacing.line }
    v(space, weak: true)
  }
}

// =============================================================================
// PARAGRAPH NUMBERING UTILITIES
// =============================================================================

/// Gets the numbering format for a specific paragraph level
/// @param level: Paragraph nesting level (0-based)
/// @returns: Numbering format function or string
#let get-paragraph-numbering-format(level) = {
  if level < paragraph-config.numbering-formats.len() {
    paragraph-config.numbering-formats.at(level)
  } else {
    "1"  // Fallback for deep nesting
  }
}

/// Generates paragraph number for a given level
/// @param level: Paragraph nesting level
/// @param counter_value: Optional explicit counter value
/// @param increment: Whether to increment the counter
/// @returns: Formatted paragraph number
#let generate-paragraph-number(level, counter-value: none, increment: false) = {
  let paragraph-counter = counter(paragraph-config.counter-prefix + str(level))
  
  if counter-value != none {
    let temp-counter = counter("temp-counter")
    temp-counter.update(counter-value)
    let numbering-format = get-paragraph-numbering-format(level)
    temp-counter.display(numbering-format)
  } else {
    let numbering-format = get-paragraph-numbering-format(level)
    let result = paragraph-counter.display(numbering-format)
    if increment { 
      paragraph-counter.step() 
    }
    result
  }
}

/// Calculates indentation width for a paragraph level
/// @param level: Paragraph nesting level
/// @returns: Indentation width measurement
#let calculate-paragraph-indent(level) = {
  if level == 0 { 
    return 0pt 
  }
  
  let parent-level = level - 1
  let parent-indent = calculate-paragraph-indent(parent-level)
  let parent-counter-value = counter(paragraph-config.counter-prefix + str(parent-level)).get().at(0) - 1
  let parent-number = generate-paragraph-number(parent-level, counter-value: parent-counter-value)

  let indent-buffer = [#h(parent-indent)#parent-number#h(spacing.two-spaces)]
  return measure(indent-buffer).width
}

/// Creates a formatted paragraph with automatic numbering and indentation
/// @param content: Paragraph content
/// @param level: Nesting level (0 for main paragraphs, 1+ for sub-paragraphs)
/// @returns: Formatted paragraph block
#let create-numbered-paragraph(content, level: 0) = {
  context {
    let paragraph-number = generate-paragraph-number(level, increment: true)
    counter(paragraph-config.counter-prefix + str(level + 1)).update(1)
    let indent-width = calculate-paragraph-indent(level)

    block[
      #v(spacing.paragraph)      
      #if paragraph-config.block-indent-state.get() {
        pad(left: indent-width)[#paragraph-number#h(spacing.two-spaces)#content]
      } else {
        pad(left: 0em)[#h(indent-width)#paragraph-number#h(spacing.two-spaces)#content]
      }
    ]
  }
}

/// Processes document body content with automatic paragraph numbering
/// @param content: Document body content
/// @returns: Processed content with numbered paragraphs
#let process-document-body(content) = {
  counter("par-counter-0").update(1)
  
  show par: it => {
    create-numbered-paragraph(it.body, level: 0)
  }
  
  content
}

// =============================================================================
// INDORSEMENT UTILITIES
// =============================================================================

/// Converts number to ordinal suffix for indorsements (1st, 2d, 3d, 4th, etc.)
/// Follows AFH 33-337 numbering conventions
/// @param number: The indorsement number
/// @returns: Ordinal suffix string
#let get-ordinal-suffix(number) = {
  let last-digit = calc.rem(number, 10)
  let last-two-digits = calc.rem(number, 100)
  
  if last-two-digits >= 11 and last-two-digits <= 13 {
    "th"
  } else if last-digit == 1 {
    "st"
  } else if last-digit == 2 {
    "d"
  } else if last-digit == 3 {
    "d"
  } else {
    "th"
  }
}

/// Formats indorsement number according to AFH 33-337 standards
/// @param number: Indorsement sequence number
/// @returns: Formatted indorsement label (e.g., "1st Ind", "2d Ind")
#let format-indorsement-number(number) = {
  let suffix = get-ordinal-suffix(number)
  str(number) + suffix + " Ind"
}

/// Processes array of indorsements for rendering
/// @param indorsements: Array of indorsement objects
/// @param body_font: Font to use for indorsement text
/// @returns: Rendered indorsements
#let process-indorsements(indorsements, body-font: "Times New Roman") = {
  if indorsements.len() > 0 {
    for indorsement in indorsements {
      (indorsement.render)(body-font: body-font)
    }
  }
}

// =============================================================================
// LEGACY COMPATIBILITY ALIASES
// =============================================================================

/// Legacy function aliases for backward compatibility
/// These will be deprecated in future versions
#let auto-grid = create-auto-grid
#let memo-par = create-numbered-paragraph
#let process-body = process-document-body
#let render-closing-section = render-closing-section
#let v-closing-leading-space = calculate-closing-spacing
#let get-ordinal-suffix = get-ordinal-suffix
#let format-indorsement-number = format-indorsement-number

/// Legacy constants for backward compatibility
#let TWO-SPACES = spacing.two-spaces
#let LINE-SPACING = spacing.line
#let BLANK-LINE = spacing.paragraph
#let TAB-SIZE = spacing.tab
#let PAR-COUNTER-PREFIX = paragraph-config.counter-prefix
#let PAR-NUMBERING-FORMATS = paragraph-config.numbering-formats
#let PAR-BLOCK-INDENT = paragraph-config.block-indent-state
#let INDORSEMENT-COUNTER = counters.indorsement
