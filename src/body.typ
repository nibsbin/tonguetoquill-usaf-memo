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


  // Number + two spaces + content, with left padding for nesting
  //pad(left: indent-width, paragraph-number + "  " + content)
  [#h(indent-width)#paragraph-number#"  "#content]
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
  let IS_HEADING = state("IS_HEADING")
  IS_HEADING.update(false)
  // Initialize level counters to 1 (Typst counters default to 0)
  for i in range(0, 5) {
    counter(paragraph-config.counter-prefix + "0").update(1)
  }

  // The first pass parses paragraphs, list items, etc. into standardized arrays
  let first_pass = {
    show heading: h => context {
      IS_HEADING.update(true)
      [#parbreak()#h.body]
      IS_HEADING.update(false)
    }

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
      let nest_level = NEST_LEVEL.get()
      let is_heading = IS_HEADING.get()
      PAR_BUFFER.update(pars => {
        pars.push((p.body, nest_level, is_heading))
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
    let heading_buffer = none
    let par_count = PAR_BUFFER.get().len()
    let i = 0
    for item in PAR_BUFFER.get() {
      i += 1
      let par_content = item.at(0)
      let nest_level = item.at(1)
      let is_heading = item.at(2)

      // Prepend heading as bolded sentence
      if heading_buffer != none {
        par_content = [#strong[#heading_buffer.] #par_content]
      }
      if is_heading {
        heading_buffer = par_content
        continue
      }

      let final_par = {
        blank-line()
        if par_count > 1 {
          // Apply paragraph numbering per AFH 33-337 §2
          SET_PAR_LEVEL(nest_level)
          let paragraph = memo-par(par_content)
          // AFH 33-337 "Continuation Pages" §11: "Type at least two lines of the text on each page.
          // Avoid dividing a paragraph of less than four lines between two pages."
          // We use Typst's orphan cost control to discourage single-line orphans
          paragraph
        } else {
          // AFH 33-337 §2: "A single paragraph is not numbered"
          // Return body content wrapped in block (like numbered case, but without numbering)
          par_content
        }
      }

      //If this is the final paragraph, make it sticky
      if i == par_count {
        // Measure line height using a reference character
        // We're already in a context block, so measure() works directly
        let line_height = measure([Xg]).height * 1.15 // Include leading
        let par_height = measure(final_par).height
        let estimated_lines = calc.ceil(par_height / line_height)

        if estimated_lines <= 2 {
          // Short paragraph: make entire thing unbreakable and sticky
          block(sticky: true, breakable: false)[#final_par]
        } else {
          // Longer paragraph: allow breaks but ensure last 2 lines stay with signature
          // High widow cost (100%) strongly discourages page breaks that would leave
          // fewer than 2 lines at the top of a page
          // sticky: true keeps this block attached to the following signature block
          block(sticky: true, breakable: true)[
            #set text(costs: (widow: 100%))
            #final_par
          ]
        }
      } else {
        final_par
      }
    }
  }
}


