// utils.typ: Utility functions and backend code for Typst USAF memo template.

//=====Configuration=====
#let TWO_SPACES = 0.5em
#let LINE_SPACING = 0.6em
#let BLANK_LINE = 1em
#let TAB_SIZE = 0.5in
#let PAR_COUNTER_PREFIX = "par-counter-"
#let PAR_NUMBERING_FORMATS = ("1.", "a.", "(1)", "(a)", n => underline(str(n)), n => underline(str(n)))
#let PAR_BLOCK_INDENT = state("BLOCK_INDENT", true)

// Indorsement counter for sequential numbering (1st Ind, 2d Ind, 3d Ind, etc.)
#let INDORSEMENT_COUNTER = counter("indorsement")

//=====Helper Functions=====

//==FRONT MATTER HELPERS
#let auto-grid(rows, column-gutter: .5em) = {
  // Convert 1D array to 2D array for consistent processing
  let normalized_rows = rows
  if rows.len() > 0 and type(rows.at(0)) != array {
    // This is a 1D array, convert each element to a single-element row
    normalized_rows = rows.map(item => (item,))
  }
  
  // Now process as 2D array - columns = max row length
  let n = calc.max(..normalized_rows.map(r => r.len()))

  // build flat list of cells (row-major)
  let cells = ()
  let make-cell = (x) => [#x]   // coerce string/content to a cell

  for row in normalized_rows {
    let k = row.len()
    for i in range(0, n) {
      let v = if i < k { row.at(i) } else { [] }
      cells.push(make-cell(v))
    }
  }

  grid(
    columns: n,
    column-gutter: column-gutter,
    row-gutter: LINE_SPACING,
    ..cells
  )
}

//==CLOSING SECTION HELPERS
// Render closing section with automatic page break handling
#let _render_closing_section(items, label, numbering_style: none, continuation_label: none) = {
  let content = {
    [#label]
    parbreak()
    if numbering_style != none { 
      // Ensure items is always an array for enum
      let item_array = if type(items) == array { items } else { (items,) }
      enum(..item_array, numbering: numbering_style) 
    } else { 
      if type(items) == array {
        items.join("\n")
      } else {
        items
      }
    }
  }
  
  context {
    let available_space = page.height - here().position().y - 1in
    if measure(content).height > available_space {
      if continuation_label != none { 
        continuation_label 
      } else { 
        label + " (listed on next page):" 
      }
      pagebreak()
    }
    content
  }
}

// Calculate leading vertical space for closing sections
#let v_closing_leading_space(is_first_closing) = {
  context {
    let space = 0em
    if not is_first_closing {
      space = 2 * LINE_SPACING
    } else {
      space = 3 * LINE_SPACING
    }
    return v(space, weak: true)
  }
}

//==PARAGRAPH HELPERS
// Get the numbering format for a level
#let _get_numbering_format(level) = {
  if level < PAR_NUMBERING_FORMATS.len() {
    PAR_NUMBERING_FORMATS.at(level)
  } else {
    "1"
  }
}
#let _get_par_num(level, counter_value:none, step:false) = {
  let par_counter = none
  if counter_value == none {
    par_counter = counter(PAR_COUNTER_PREFIX + str(level))
  }
  else {
    par_counter = counter("temp-counter")
    par_counter.update(counter_value)
  }

  let numbering_format = _get_numbering_format(level)
  par_counter.display(numbering_format)
  if step { par_counter.step()}
}

// Get the indent width for a level
#let _get_paragraph_indent(level) = {
  if level == 0 { return 0pt }
  let parent_level = level - 1
  let parent_indent = _get_paragraph_indent(parent_level)
  let parent_val = counter(PAR_COUNTER_PREFIX + str(parent_level)).get().at(0) - 1 // undo the last step
  let parent_num = _get_par_num(parent_level, counter_value: parent_val)

  let buffer = [#h(parent_indent)#parent_num#h(TWO_SPACES)]

  return measure(buffer).width
}

#let _make_par(level, content) = {
  context {
    let num = _get_par_num(level, step:true)
    counter(PAR_COUNTER_PREFIX + str(level + 1)).update(1)
    let indent_amount = _get_paragraph_indent(level)

    block[
      #v(BLANK_LINE)
      #if PAR_BLOCK_INDENT.get() {
        pad(left: indent_amount)[#num#h(TWO_SPACES)#content]
      } else {
        pad(left:0em)[#h(indent_amount)#num#h(TWO_SPACES)#content]
      }
    ]
  }
}

#let _process_body(content, base-par) = {
  counter("par-counter-0").update(1)
  
  show par: it => {
    let content_str = repr(it.body)
    if content_str.contains("grid(") {
      it // Already formatted paragraph
    } else {
      base-par(it.body) // Wrap raw paragraph
    }
  }
  
  content
}

//==INDORSEMENT HELPERS
// Convert number to ordinal suffix for indorsements (1st, 2d, 3d, 4th, etc.)
#let _get_ordinal_suffix(n) = {
  let last_digit = calc.rem(n, 10)
  let last_two_digits = calc.rem(n, 100)
  
  if last_two_digits >= 11 and last_two_digits <= 13 {
    "th"
  } else if last_digit == 1 {
    "st"
  } else if last_digit == 2 {
    "d"
  } else if last_digit == 3 {
    "d"
  } else {
    "th"
  }
}

// Format indorsement number according to AFH 33-337 standards
#let _format_indorsement_number(n) = {
  let suffix = _get_ordinal_suffix(n)
  str(n) + suffix + " Ind"
}

// Render indorsements within the main memo template  
#let process_indorsements(indorsements, body_font: "Times New Roman") = {
  if indorsements.len() > 0 {
    for indorsement in indorsements {
      indorsement.render(body_font: body_font)
    }
  }
}
