use tonguetoquill_typst_writer::markdown_to_typst;

fn main() {
    let markdown = r#"# Sample Document

This is a paragraph with **bold text** and _italic text_.

Here's a [link to example](https://example.com).

## Lists

Simple list:
- First item
- Second item 
- Third item

Nested list:
- Top level item
  - Nested item 1
    - Deep nested item
  - Nested item 2
- Another top level item

## Text Formatting

This paragraph contains *emphasis*, **strong text**, and ~~strikethrough~~.

Special characters like #hashtag and $math$ are properly escaped.

Use `inline code` for functions.
"#;

    let typst_output = markdown_to_typst(markdown);
    println!("Markdown input:");
    println!("{}", markdown);
    println!("\nTypst output:");
    println!("{}", typst_output);
}