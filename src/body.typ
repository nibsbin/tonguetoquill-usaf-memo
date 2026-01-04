// body.typ: Paragraph body rendering for USAF memorandum sections
//
// This module implements the visual rendering of AFH 33-337 compliant
// paragraph bodies with proper numbering, nesting, and formatting.

#import "config.typ": *
#import "utils.typ": *

// =============================================================================
// PARAGRAPH NUMBERING UTILITIES
// =============================================================================

/// Gets the numbering format for a specific paragraph level.
///
/// AFH 33-337 "The Text of the Official Memorandum" §2: "Number and letter each
/// paragraph and subparagraph" with hierarchical numbering implied by examples.
/// Standard military format follows the pattern: 1., a., (1), (a), etc.
///
/// Returns the appropriate numbering format for AFH 33-337 compliant
/// hierarchical paragraph numbering:
/// - Level 0: "1." (1., 2., 3., etc.)
/// - Level 1: "a." (a., b., c., etc.)
/// - Level 2: "(1)" ((1), (2), (3), etc.)
/// - Level 3: "(a)" ((a), (b), (c), etc.)
/// - Level 4+: Underlined format for deeper nesting
///
/// - level (int): Paragraph nesting level (0-based)
/// -> str | function
#let get-paragraph-numbering-format(level) = {
  paragraph-config.numbering-formats.at(level, default: "i.")
}

/// Generates paragraph number for a given level with proper formatting.
///
/// Creates properly formatted paragraph numbers for the hierarchical numbering
/// system using Typst's native counter display capabilities.
///
/// - level (int): Paragraph nesting level (0-based)
/// - counter-value (none | int): Optional explicit counter value to use (for measuring widths)
/// - increment (bool): Whether to increment the counter after display
/// -> content
#let generate-paragraph-number(level, counter-value: none) = {
  let paragraph-counter = counter(paragraph-config.counter-prefix + str(level))
  let numbering-format = get-paragraph-numbering-format(level)

  if counter-value != none {
    // For measuring widths: create temporary counter at specific value
    assert(counter-value >= 0, message: "Counter value of `" + str(counter-value) + "` cannot be less than 0")
    let temp-counter = counter("temp-counter")
    temp-counter.update(counter-value)
    temp-counter.display(numbering-format)
  } else {
    // Standard case: display and increment
    let result = paragraph-counter.display(numbering-format)
    paragraph-counter.step()
    result
  }
}

/// Calculates proper indentation width for a paragraph level.
///
/// AFH 33-337 "The Text of the Official Memorandum" §4-5:
/// - "The first paragraph is never indented; it is numbered and flush left"
/// - "Indent the first line of sub-paragraphs to align the number or letter with
///    the first character of its parent level paragraph"
///
/// Computes the exact indentation needed for hierarchical paragraph alignment
/// by measuring the cumulative width of all ancestor paragraph numbers and their
/// spacing. Uses direct iteration instead of recursion for better performance.
///
/// Per AFH 33-337: Sub-paragraph text aligns with first character of parent text,
/// which means indentation = sum of all ancestor number widths + spacing.
///
/// - level (int): Paragraph nesting level (0-based)
/// -> length
#let calculate-paragraph-indent(level) = {
  assert(level >= 0)
  if level == 0 {
    return 0pt
  }

  // Accumulate widths of all ancestor numbers iteratively
  let total-indent = 0pt
  for ancestor-level in range(level) {
    let ancestor-counter-value = counter(paragraph-config.counter-prefix + str(ancestor-level)).get().at(0)
    let ancestor-number = generate-paragraph-number(ancestor-level, counter-value: ancestor-counter-value)
    // Measure number + spacing buffer
    let width = measure([#ancestor-number#"  "]).width
    total-indent += width
  }

  total-indent
}

/// Global state for tracking current paragraph level.
/// Used internally by the paragraph numbering system to maintain proper nesting.
/// -> state
#let PAR_LEVEL_STATE = state("PAR_LEVEL", 0)

/// Global state for storing the last body paragraph.
/// Used by render-signature-block to wrap the last paragraph in a sticky block
/// with the signature, preventing orphaned signature blocks per AFH 33-337.
/// -> state
#let LAST_PARAGRAPH_STATE = state("LAST_PARAGRAPH", none)

/// Sets the current paragraph level state.
///
/// Internal function used by the paragraph numbering system to track
/// the current nesting level for proper indentation and numbering.
///
/// - level (int): Paragraph nesting level to set
/// -> content
#let SET_PAR_LEVEL(level) = {
  context {
    PAR_LEVEL_STATE.update(level)
    if level == 0 {
      counter(paragraph-config.counter-prefix + str(level + 1)).update(1)
    }
  }
}

/// Creates a formatted paragraph with automatic numbering and indentation.
///
/// Generates a properly formatted paragraph with AFH 33-337 compliant numbering,
/// indentation, and spacing. Automatically manages counter incrementation and
/// nested paragraph state. Used internally by the body rendering system.
///
/// Features:
/// - Automatic paragraph number generation and formatting
/// - Proper indentation based on nesting level via direct width measurement
/// - Counter management for hierarchical numbering
/// - Widow/orphan prevention settings
///
/// - content (content): Paragraph content to format
/// -> content
#let memo-par(content) = context {
  let level = PAR_LEVEL_STATE.get()
  let paragraph-number = generate-paragraph-number(level)
  // Reset child level counter
  counter(paragraph-config.counter-prefix + str(level + 1)).update(1)
  let indent-width = calculate-paragraph-indent(level)

  set text(costs: (widow: 0%))

  // Number + two spaces + content, with left padding for nesting
  pad(left: indent-width, paragraph-number + "  " + content)
}

// =============================================================================
// PARAGRAPH BODY RENDERING
// =============================================================================
// AFH 33-337 "The Text of the Official Memorandum" §1-12 specifies:
// - Single-space text, double-space between paragraphs
// - Number and letter each paragraph and subparagraph
// - "A single paragraph is not numbered" (§2)
// - First paragraph flush left, never indented
// - Indent sub-paragraphs to align with first character of parent paragraph text
#let render-body(content) = {
  let PAR_BUFFER = state("PAR_BUFFER")
  PAR_BUFFER.update(())
  let NEST_LEVEL = state("ENUM_LEVEL")
  NEST_LEVEL.update(0)
  // Initialize level counters to 1 (Typst counters default to 0)
  for i in range(0, 5) {
    counter(paragraph-config.counter-prefix + "0").update(1)
  }


  let first_pass = {
    // Convert list/enum items to pars
    show enum.item: it => context {
      [#parbreak()#it]
    }
    show list.item: it => context {
      [#parbreak()#it]
    }
    // Track nesting level of list/enum
    show list: l => context {
      NEST_LEVEL.update(l => l + 1)
      l
      NEST_LEVEL.update(l => l - 1)
    }
    show enum: l => context {
      NEST_LEVEL.update(l => l + 1)
      l
      NEST_LEVEL.update(l => l - 1)
    }

    // Collect pars with nesting level
    show par.where(): p => context {
      let nest-level = NEST_LEVEL.get()

      PAR_BUFFER.update(pars => {
        pars.push((p.body, nest-level))
        pars
      })
      p
    }
    content
  }
  // Use place() to prevent hidden content from affecting layout flow
  place(hide(first_pass))

  //Second pass: consume par buffer
  context {
    let should_number = PAR_BUFFER.get().len() > 1
    for item in PAR_BUFFER.get() {
      blank-line()
      let par_content = item.at(0)
      let nest_level = item.at(1)

      if should_number {
        // Apply paragraph numbering per AFH 33-337 §2
        SET_PAR_LEVEL(nest_level)
        let paragraph = memo-par(par_content)
        // AFH 33-337 "Continuation Pages" §11: "Type at least two lines of the text on each page.
        // Avoid dividing a paragraph of less than four lines between two pages."
        // We use Typst's orphan cost control to discourage single-line orphans
        set text(costs: (orphan: 0%))
        block(breakable: true)[#paragraph]
      } else {
        // AFH 33-337 §2: "A single paragraph is not numbered"
        // Return body content wrapped in block (like numbered case, but without numbering)
        set text(costs: (orphan: 0%))
        block(breakable: true)[#par_content]
      }
    }
  }
}
}

#let render-paragraph-body-old(content) = {
  // Initialize base level counter
  counter("par-counter-0").update(1)

  // AFH 33-337: "Number and letter each paragraph and subparagraph. A single
  // paragraph is not numbered."
  // Count paragraphs using repr() introspection
  let content-str = repr(content)

  // Detect multiple paragraphs by looking for parbreak() between content elements
  // Pattern: content, parbreak(), content
  // This matches parbreak() BETWEEN content, not trailing parbreaks
  let has-multiple-pars = (
    content-str.contains("parbreak(),")
      and content-str.matches(regex("(\\]|\\)),\\s*parbreak\\(\\),\\s*(\\[|[a-zA-Z_][a-zA-Z0-9_]*\\()")).len() > 0
  )

  // Render with paragraph numbering based on detection
  context {
    let should-number = has-multiple-pars

    // Track nesting level for enum/list items
    let enum-level = state("enum-level", 1)

    // State to track pending heading text that should be prepended to next paragraph
    let pending-heading = state("pending-heading", none)

    // Suppress default enum/list rendering - we'll handle it via nested paragraphs
    show enum.item: _enum_item => {}
    show list.item: _list_item => {}

    // Intercept enum items to set nesting level
    show enum.item: _enum_item => context {
      enum-level.update(l => l + 1)
      SET_PAR_LEVEL(enum-level.get())

      // Don't render the enum marker - render body content as nested paragraphs instead
      v(0em, weak: true)
      _enum_item.body

      // Reset level after nested content
      SET_PAR_LEVEL(0)
      enum-level.update(l => l - 1)
    }

    // Intercept list items to set nesting level
    show list.item: list_item => context {
      enum-level.update(l => l + 1)
      SET_PAR_LEVEL(enum-level.get())

      // Don't render the list marker - render body content as nested paragraphs instead
      v(0em, weak: true)
      list_item.body

      // Reset level after nested content
      SET_PAR_LEVEL(0)
      enum-level.update(l => l - 1)
    }

    // Intercept headings to render as bold paragraph headings
    // AFH 33-337: Headings within memo body should be rendered as bold text
    // prepended to the following paragraph, not as standalone heading elements.
    // Store heading in state to be consumed by the next paragraph.
    show heading: it => context {
      // Store heading text in state to prepend to next paragraph
      pending-heading.update(it.body)
      // Return empty content - heading will be rendered with the paragraph
      v(0em, weak: true)
    }

    // Intercept paragraphs for numbering
    show par: it => context {
      // Check if there's a pending heading to prepend
      let heading-text = pending-heading.get()

      // Build paragraph content with optional heading prefix
      let paragraph-content = if heading-text != none {
        // Clear the pending heading
        pending-heading.update(none)
        // Prepend bold heading text with period and space to paragraph body
        [*#heading-text.* #it.body]
      } else {
        it.body
      }

      blank-line()
      if should-number {
        // Apply paragraph numbering per AFH 33-337 §2
        let paragraph = memo-par(paragraph-content)
        // AFH 33-337 "Continuation Pages" §11: "Type at least two lines of the text on each page.
        // Avoid dividing a paragraph of less than four lines between two pages."
        // We use Typst's orphan cost control to discourage single-line orphans
        set text(costs: (orphan: 0%))
        block(breakable: true)[#paragraph]
      } else {
        // AFH 33-337 §2: "A single paragraph is not numbered"
        // Return body content wrapped in block (like numbered case, but without numbering)
        set text(costs: (orphan: 0%))
        block(breakable: true)[#paragraph-content]
      }
    }

    // Reset to base level and render content
    SET_PAR_LEVEL(0)
    content
  }
}
