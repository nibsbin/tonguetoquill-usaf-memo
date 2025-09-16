# Integration Guide: Using TypstWriter with tonguetoquill-usaf-memo

This guide shows how to integrate the new TypstWriter with the existing tonguetoquill-usaf-memo project to enable Markdown-to-Typst conversion for USAF memo content.

## Overview

The TypstWriter provides a minimal but robust library for converting Markdown to Typst format. It can be integrated with this project to allow users to write memo content in Markdown and have it automatically converted to proper Typst syntax for the USAF memo template.

## Integration Options

### Option 1: Command-Line Tool

Create a CLI tool that converts Markdown files to Typst format, which can then be used with the existing memo template:

```rust
// Example: rust_src/bin/md2typst.rs
use tonguetoquill_typst_writer::markdown_to_typst;
use std::{env, fs, process};

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() != 3 {
        eprintln!("Usage: {} <input.md> <output.typ>", args[0]);
        process::exit(1);
    }

    let input_path = &args[1];
    let output_path = &args[2];

    let markdown = fs::read_to_string(input_path)
        .expect("Failed to read input file");
    
    let typst = markdown_to_typst(&markdown);
    
    fs::write(output_path, typst)
        .expect("Failed to write output file");
    
    println!("Converted {} to {}", input_path, output_path);
}
```

### Option 2: Template Integration

Modify the existing Typst templates to accept converted content:

```typst
// Example integration in template files
#import "path/to/rust_conversion": convert_markdown_to_typst

#let memo_with_markdown(
  // ... existing parameters
  body_markdown: none,
  body_typst: none,
) = {
  let final_body = if body_markdown != none {
    // Convert markdown to typst using the Rust library
    convert_markdown_to_typst(body_markdown)
  } else {
    body_typst
  }
  
  // Use existing memo template with converted content
  official-memorandum(
    // ... other parameters
    body: final_body,
  )
}
```

### Option 3: Build Script Integration

Add Markdown preprocessing to the build process:

```bash
# Enhanced build.sh
#!/bin/bash

# Convert markdown files to typst first
for md_file in content/*.md; do
  if [ -f "$md_file" ]; then
    typ_file="${md_file%.md}.typ"
    cargo run --bin md2typst "$md_file" "$typ_file"
  fi
done

# Then run existing build process
echo "Compiling templates and tests to PDFs..."
typst compile --font-path . template/starkindustries.typ pdfs/starkindustries.pdf
# ... rest of build script
```

## Example Workflow

### 1. Write Content in Markdown

```markdown
# Memorandum Subject

This memorandum addresses the following concerns:

- **Operational Requirements**: Ensure all units comply with new protocols
- **Training Standards**: Updated certification requirements
  - Initial certification must be completed by end of quarter
  - Annual recertification is mandatory
- **Resource Allocation**: Budget considerations for next fiscal year

Please review the attached documents and provide feedback via the [feedback portal](https://feedback.example.mil).

*This document contains sensitive information* and should be handled accordingly.
```

### 2. Convert to Typst

Using the TypstWriter, this becomes:

```typst
= Memorandum Subject

This memorandum addresses the following concerns:

- *Operational Requirements*: Ensure all units comply with new protocols
- *Training Standards*: Updated certification requirements
  + Initial certification must be completed by end of quarter
  + Annual recertification is mandatory
- *Resource Allocation*: Budget considerations for next fiscal year

Please review the attached documents and provide feedback via the #link("https://feedback.example.mil")[feedback portal].

_This document contains sensitive information_ and should be handled accordingly.
```

### 3. Use with USAF Memo Template

```typst
#import "@preview/tonguetoquill-usaf-memo:0.1.0": official-memorandum

// Convert markdown content
#let body_content = convert_markdown_content("content/memo_body.md")

#official-memorandum(
  letterhead-title: "DEPARTMENT OF THE AIR FORCE",
  letterhead-caption: "HEADQUARTERS UNITED STATES AIR FORCE",
  date: "1 January 2024",
  memo-for: "ALL PERSONNEL",
  from-name: "JOHN A. DOE",
  from-title: "Colonel, USAF",
  from-org: "Commander",
  subject: "Implementation of New Protocols",
  body: body_content,
  signature-block: (
    "JOHN A. DOE, Colonel, USAF",
    "Commander"
  ),
)
```

## Benefits

1. **Easier Content Creation**: Authors can write in familiar Markdown syntax
2. **Consistent Formatting**: Automatic conversion ensures proper Typst formatting
3. **Version Control Friendly**: Markdown files diff better than Typst markup
4. **Collaboration**: Non-technical users can contribute content in Markdown
5. **Validation**: The conversion process can include content validation

## Current Limitations

The TypstWriter currently supports only the essential features requested:
- Paragraphs
- Nested lists
- Text styles (emphasis, strong, strikethrough)
- Links
- Headings
- Inline code

Additional Markdown features (tables, images, etc.) would need to be added based on requirements.

## Future Enhancements

Potential improvements for better integration:

1. **Table Support**: Convert Markdown tables to Typst table syntax
2. **Image Handling**: Process image references and paths
3. **Metadata Processing**: Handle YAML frontmatter for memo parameters
4. **Custom Extensions**: Support for USAF-specific markup extensions
5. **Validation**: Ensure converted content meets AFH 33-337 requirements