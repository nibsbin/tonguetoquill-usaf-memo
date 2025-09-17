// utils.typ: Utility functions and backend code for Typst usaf-memo package.

// =============================================================================
// CONFIGURATION CONSTANTS
// =============================================================================

/// Spacing constants following AFH 33-337 standards.
/// -> dictionary
#let spacing = (
  two-spaces: 0.5em,      // Standard two-space separator
  line:.5em,            // Line spacing within paragraphs
  line-height:.7em,      //base height for lines
  tab: 0.5in,             // Tab stop for alignment
  margin:1in            // Standard page margin
)

/// Configures document typography and layout settings according to AFH 33-337 standards.
/// Applies consistent font, paragraph, and block styling throughout the document.
/// - body-font (str | array): Font family(ies) to use for body text.
/// - ctx (content): Content to apply configuration to.
/// -> content
#let configure(body-font,ctx) = {
  context{
    set par(leading: spacing.line, justify: true)
    set block(above:spacing.line, below:0em,spacing: 0em)
    set text(font: body-font, size: 12pt, fallback: false)
    ctx
  }
}

/// Creates vertical spacing with multiple blank lines.
/// Uses AFH 33-337 compliant line spacing calculations.
/// - count (int): Number of blank lines to insert.
/// - weak (bool): Whether spacing can be compressed at page boundaries.
/// -> content
#let blank-lines(count,weak:true) = {
  let lead = spacing.line
  let height = spacing.line-height
  v(lead + (height + lead) * count,weak:weak)
}

/// Creates a single blank line with proper AFH 33-337 spacing.
/// - weak (bool): Whether spacing can be compressed at page boundaries.
/// -> content
#let blank-line(weak:true) = blank-lines(1,weak:weak)

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
// MISC UTILITIES
// =============================================================================

/// Checks if a value is "falsey" (none, false, empty array, or empty string).
/// Useful for testing optional parameters and content before rendering.
/// - value (any): The value to check for "falsey" status.
/// -> bool
#let falsey(value) = {
  value == none or value == false or (type(value) == array and value.len() == 0) or (type(value) == str and value == "")
}

/// Scales and fits content within a fixed-size box with specified alignment.
/// Maintains aspect ratio while ensuring content fits within box dimensions.
/// - width (length): Maximum width of the container box.
/// - height (length): Maximum height of the container box. 
/// - alignment (alignment): How to align content within the box (default: left+horizon).
/// - body (content): Content to scale and fit within the box.
/// -> content
#let fit-box(width: 2in, height: 1in, alignment:left+horizon, body) = context {
  // 1) measure the unscaled content
  let s = measure(body)

  // 2) compute the uniform scale that fits inside the box
  let f = calc.min(width / s.width, height / s.height) * 100%  // ratio

  // 3) fixed-size box, center the scaled content, and reflow so layout respects it
  box(width: width, height: height, clip: true)[
    #align(alignment)[
      #scale(f, reflow: true)[#body]
    ]
  ]
}

/// Formats a datetime object into AFH 33-337 compliant date display format.
/// Returns date in "DD Month YYYY" format (e.g., "1 January 2024").
/// - date (datetime): The date to format and display.
/// -> str
#let display-date(date) = {
  date.display("[day padding:none] [month repr:long] [year]")
}

// =============================================================================
// GRID LAYOUT UTILITIES
// =============================================================================

/// Creates an automatic grid layout from 1D or 2D array.
/// - content (str | array): Content to arrange in grid.
/// - column-gutter (length): Space between columns.
/// - columns (int): Number of columns for the grid.
/// -> grid
#let create-auto-grid(content, column-gutter: .5em, cols: 3) = {
  let content_type = type(content)
  
  assert(content_type == str or content_type == array, message: "Content must be a string or an array of strings.")
  if content_type == array {
    for item in content {
      assert(type(item) == str, message: "All items in content array must be strings.")
    }
  }

  // Normalize to 1d array
  if content_type == str {
    content = (content,)
  }


  // Build cell array in row-major order
  let cells = ()
  let i = 0
  for item in content {
    i += 1
    cells.push(item)
    if calc.rem(i, cols) == 0 {
      // Add empty cell to pad the page
      cells.push([])
    }
  }

  grid(
    columns: calc.max(1, cols) + 1,
    column-gutter: .1fr,
    row-gutter: spacing.line,
    ..cells
  )
}

// =============================================================================
// BACKMATTER SECTION UTILITIES
// =============================================================================

/// Renders backmatter sections with intelligent page break handling.
/// - content (content): Section content to render.
/// - section-label (str): Label for the section (e.g., "Attachments:").
/// - numbering-style (none | str | function): Optional numbering format for lists.
/// - continuation-label (none | str): Label when content continues on next page.
/// -> content
#let render-backmatter-section(
  content, 
  section-label, 
  numbering-style: none, 
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
/// - is-first-section (bool): Whether this is the first backmatter section.
/// -> content
#let calculate-backmatter-spacing(is-first-section) = {
  context {
    let line_count = if is-first-section { 2 } else { 1 }
    blank-lines(line_count)
    
  }
}

// =============================================================================
// PARAGRAPH NUMBERING UTILITIES
// =============================================================================

/// Gets the numbering format for a specific paragraph level.
/// - level (int): Paragraph nesting level (0-based).
/// -> str | function
#let get-paragraph-numbering-format(level) = {
  if level < paragraph-config.numbering-formats.len() {
    paragraph-config.numbering-formats.at(level)
  } else {
    "i."  // Fallback for deep nesting
  }
}

/// Generates paragraph number for a given level.
/// - level (int): Paragraph nesting level.
/// - counter-value (none | int): Optional explicit counter value.
/// - increment (bool): Whether to increment the counter.
/// -> content
#let generate-paragraph-number(level, counter-value: none, increment: false) = {
  let paragraph-counter = counter(paragraph-config.counter-prefix + str(level))
  
  if counter-value != none {
    assert(counter-value >= 0,message: "Counter value of `" + str(counter-value) + "` cannot be less than 0")
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
/// - level (int): Paragraph nesting level.
/// -> length
#let calculate-paragraph-indent(level) = {
  assert(level >= 0)
  if level == 0 { 
    return 0pt 
  }
  
  let parent-level = level - 1
  let parent-indent = calculate-paragraph-indent(parent-level)
  let parent-counter = counter(paragraph-config.counter-prefix + str(parent-level)).get().at(0) 
  let parent-counter-value = counter(paragraph-config.counter-prefix + str(parent-level)).get().at(0)
  let parent-number = generate-paragraph-number(parent-level, counter-value: parent-counter-value)

  let indent-buffer = [#h(parent-indent)#parent-number#h(spacing.two-spaces)]
  return measure(indent-buffer).width
}

/// Global state tracking current paragraph nesting level for automatic numbering.
/// Used internally by the paragraph numbering system.
/// -> state
#let PAR_LEVEL_STATE = state("PAR_LEVEL", 0)

/// Sets the current paragraph nesting level for automatic numbering.
/// Used internally by enum processing to track hierarchy depth.
/// - level (int): The nesting level to set (0 for base level, 1+ for sub-levels).
/// -> content
#let SET_LEVEL(level) = {
  context {
    PAR_LEVEL_STATE.update(level)
  }
}

/// Creates a formatted paragraph with automatic numbering and indentation.
/// - content (content): Paragraph content.
/// - level (int): Nesting level (0 for main paragraphs, 1+ for sub-paragraphs).
/// -> content
#let memo-par(content) = {
  context {
    let level = PAR_LEVEL_STATE.get()
    let paragraph-number = generate-paragraph-number(level, increment: true)
    counter(paragraph-config.counter-prefix + str(level + 1)).update(1)
    let indent-width = calculate-paragraph-indent(level) 

    let output = {
      if paragraph-config.block-indent-state.get() {
        pad(left: indent-width)[#paragraph-number#h(spacing.two-spaces)#content]
      } else {
        pad(left: 0em)[#h(indent-width)#paragraph-number#h(spacing.two-spaces)#content]
      }
    }
    output
  }
}

// =============================================================================
// INDORSEMENT UTILITIES
// =============================================================================

/// Converts number to ordinal suffix for indorsements (1st, 2d, 3d, 4th, etc.).
/// Follows AFH 33-337 numbering conventions.
/// - number (int): The indorsement number.
/// -> str
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

/// Formats indorsement number according to AFH 33-337 standards.
/// - number (int): Indorsement sequence number.
/// -> str
#let format-indorsement-number(number) = {
  let suffix = get-ordinal-suffix(number)
  str(number) + suffix + " Ind"
}

/// Processes array of indorsements for rendering.
/// - indorsements (array): Array of indorsement objects.
/// - body-font (str): Font to use for indorsement text.
/// -> content
#let process-indorsements(indorsements, body-font: none) = {
  if not falsey(indorsements) {
    for indorsement in indorsements {
      (indorsement.render)(body-font: body-font)
    }
  }
}