# Typst Writer for Markdown Conversion

This Rust library provides a `TypstWriter` that converts Markdown to Typst format using the pulldown-cmark parser. It focuses on the essential features required for document conversion.

## Supported Features

The library currently supports conversion of the following Markdown elements to Typst:

### Text Formatting
- **Paragraphs**: Converted with proper spacing
- **Emphasis** (`_italic_`): Converted to Typst `_italic_` syntax
- **Strong** (`**bold**`): Converted to Typst `*bold*` syntax  
- **Strikethrough** (`~~text~~`): Converted to Typst `#strike[text]` function
- **Inline code** (`` `code` ``): Converted to Typst `#raw("code")` function

### Links
- **Links** (`[text](url)`): Converted to Typst `#link("url")[text]` function

### Lists
- **Unordered lists**: Converted to Typst bullet lists with `-` markers
- **Nested lists**: Properly indented with alternating `+` and `-` markers based on nesting level

### Headings
- **Headings** (`# Title`): Converted to Typst heading syntax (`= Title`)
- All heading levels supported (H1-H6)

## Usage

### Basic Usage

```rust
use tonguetoquill_typst_writer::markdown_to_typst;

let markdown = "This is **bold** and _italic_ text with a [link](https://example.com).";
let typst = markdown_to_typst(markdown);
println!("{}", typst);
```

### Advanced Usage

```rust
use tonguetoquill_typst_writer::TypstWriter;
use pulldown_cmark::{Parser, Options};

let markdown = "Your markdown content here";

// Enable strikethrough parsing
let mut options = Options::empty();
options.insert(Options::ENABLE_STRIKETHROUGH);

let parser = Parser::new_ext(markdown, options);
let mut output = String::new();
let writer = TypstWriter::new(&mut output);
let _result = writer.run(parser).unwrap();

println!("{}", output);
```

## Design Decisions

### Minimal and Focused
This implementation focuses only on the specified features:
- Paragraphs
- Nested lists  
- Text styles (emphasis, strong, strikethrough)
- Links
- Headings (added for completeness)
- Inline code (added for completeness)

Other Markdown features are intentionally not implemented to keep the library minimal and focused.

### Safety and Escaping
The library properly escapes special Typst characters in text content:
- `#` → `\#`
- `$` → `\$`
- `*` → `\*` (when not part of formatting)
- `_` → `\_` (when not part of formatting)
- `@` → `\@`
- `<` → `\<`
- `>` → `\>`
- `` ` `` → `` \` ``
- `\` → `\\`

### List Formatting
Nested lists use alternating markers:
- Odd levels (1, 3, 5...): Use `-` (bullet lists)
- Even levels (2, 4, 6...): Use `+` (numbered lists)

This provides visual distinction between nesting levels in the Typst output.

## Testing

The library includes comprehensive tests for all supported features:

```bash
cargo test
```

## Example

Run the included example to see the conversion in action:

```bash
cargo run --example basic
```

This will demonstrate conversion of various Markdown elements to their Typst equivalents.