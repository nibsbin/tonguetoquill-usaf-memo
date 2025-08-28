// utils.typ: Utility functions and backend code for Typst USAF memo template.

// =============================================================================
// CONFIGURATION CONSTANTS
// =============================================================================

/// Spacing constants following AFH 33-337 standards.
/// -> dictionary
#let spacing = (
  two-spaces: 0.5em,      // Standard two-space separator
  line: 0.5em,            // Line spacing within paragraphs
  paragraph: 1em,         // Blank line between paragraphs
  tab: 0.5in,             // Tab stop for alignment
)

/// Paragraph numbering configuration dictionary.
/// -> dictionary
#let paragraph-config = (
  counter-prefix: "par-counter-",
  numbering-formats: ("1.", "a.", "(1)", "(a)", n => underline(str(n)), n => underline(str(n))),
  block-indent-state: state("BLOCK_INDENT", true),
)

/// Global counters for document structure.
/// -> dictionary
#let counters = (
  indorsement: counter("indorsement"),
)

// =============================================================================
// GRID LAYOUT UTILITIES
// =============================================================================

/// Creates an automatic grid layout from 1D or 2D array.
/// -> grid
#let create-auto-grid(
  /// Array of content (1D or 2D). -> array
  rows, 
  /// Space between columns. -> length
  column-gutter: .5em
) = {
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
// BACKMATTER SECTION UTILITIES
// =============================================================================

/// Renders backmatter sections with intelligent page break handling.
/// -> content
#let render-backmatter-section(
  /// Section content to render. -> content
  content, 
  /// Label for the section (e.g., "Attachments:"). -> str
  section-label, 
  /// Optional numbering format for lists. -> none | str | function
  numbering-style: none, 
  /// Label when content continues on next page. -> none | str
  continuation-label: none
) = {
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

/// Calculates vertical spacing before backmatter sections.
/// -> content
#let calculate-backmatter-spacing(
  /// Whether this is the first backmatter section. -> bool
  is-first-section
) = {
  context {
    let space = if is-first-section { 3 * spacing.line } else { 2 * spacing.line }
    v(space, weak: true)
  }
}

// =============================================================================
// PARAGRAPH NUMBERING UTILITIES
// =============================================================================

/// Gets the numbering format for a specific paragraph level.
/// -> str | function
#let get-paragraph-numbering-format(
  /// Paragraph nesting level (0-based). -> int
  level
) = {
  if level < paragraph-config.numbering-formats.len() {
    paragraph-config.numbering-formats.at(level)
  } else {
    "1"  // Fallback for deep nesting
  }
}

/// Generates paragraph number for a given level.
/// -> content
#let generate-paragraph-number(
  /// Paragraph nesting level. -> int
  level, 
  /// Optional explicit counter value. -> none | int
  counter-value: none, 
  /// Whether to increment the counter. -> bool
  increment: false
) = {
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

/// Calculates indentation width for a paragraph level.
/// -> length
#let calculate-paragraph-indent(
  /// Paragraph nesting level. -> int
  level
) = {
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

/// Creates a formatted paragraph with automatic numbering and indentation.
/// -> content
#let create-numbered-paragraph(
  /// Paragraph content. -> content
  content, 
  /// Nesting level (0 for main paragraphs, 1+ for sub-paragraphs). -> int
  level: 0
) = {
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

/// Processes document body content with automatic paragraph numbering.
/// -> content
#let process-document-body(
  /// Document body content. -> content
  content
) = {
  counter("par-counter-0").update(1)
  
  show par: it => {
    create-numbered-paragraph(it.body, level: 0)
  }
  
  content
}

// =============================================================================
// INDORSEMENT UTILITIES
// =============================================================================

/// Converts number to ordinal suffix for indorsements (1st, 2d, 3d, 4th, etc.).
/// Follows AFH 33-337 numbering conventions.
/// -> str
#let get-ordinal-suffix(
  /// The indorsement number. -> int
  number
) = {
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

/// Formats indorsement number according to AFH 33-337 standards.
/// -> str
#let format-indorsement-number(
  /// Indorsement sequence number. -> int
  number
) = {
  let suffix = get-ordinal-suffix(number)
  str(number) + suffix + " Ind"
}

/// Processes array of indorsements for rendering.
/// -> content
#let process-indorsements(
  /// Array of indorsement objects. -> array
  indorsements, 
  /// Font to use for indorsement text. -> str
  body-font: "Times New Roman"
) = {
  if indorsements.len() > 0 {
    for indorsement in indorsements {
      (indorsement.render)(body-font: body-font)
    }
  }
}

// =============================================================================
// DEPRECATED FEATURES REMOVED
// =============================================================================

// Legacy compatibility aliases have been removed to enforce modern API usage.
// Use the standard function names instead of legacy aliases.
// Removed deprecated constants and function aliases for cleaner codebase.
