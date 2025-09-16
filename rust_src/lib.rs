//! A minimal Typst writer for converting Markdown to Typst using pulldown-cmark.
//!
//! This library provides a `TypstWriter` that converts specific Markdown events to Typst format:
//! - Paragraphs
//! - Nested lists
//! - Text styles (emphasis, strong, strikethrough)
//! - Links
//!
//! Based on pulldown-cmark's HtmlWriter with Typst-specific formatting.

use pulldown_cmark::{Event, Tag, TagEnd};
use std::fmt::Write;

/// A writer that converts pulldown-cmark Events to Typst format.
pub struct TypstWriter<W> {
    writer: W,
    /// Whether the last write ended with a newline
    end_newline: bool,
    /// Current list nesting level
    list_level: usize,
}

impl<W> TypstWriter<W>
where
    W: Write,
{
    /// Create a new TypstWriter with the given writer.
    pub fn new(writer: W) -> Self {
        Self {
            writer,
            end_newline: true,
            list_level: 0,
        }
    }

    /// Write a string to the output, tracking newlines.
    fn write(&mut self, s: &str) -> Result<(), std::fmt::Error> {
        self.writer.write_str(s)?;
        if !s.is_empty() {
            self.end_newline = s.ends_with('\n');
        }
        Ok(())
    }

    /// Write a newline if the last output didn't end with one.
    fn ensure_newline(&mut self) -> Result<(), std::fmt::Error> {
        if !self.end_newline {
            self.write("\n")?;
        }
        Ok(())
    }

    /// Process an iterator of events, converting them to Typst format.
    pub fn run<'a, I>(mut self, events: I) -> Result<W, std::fmt::Error>
    where
        I: Iterator<Item = Event<'a>>,
    {
        for event in events {
            self.process_event(event)?;
        }
        Ok(self.writer)
    }

    /// Process a single event.
    fn process_event(&mut self, event: Event<'_>) -> Result<(), std::fmt::Error> {
        match event {
            Event::Start(tag) => self.start_tag(tag)?,
            Event::End(tag_end) => self.end_tag(tag_end)?,
            Event::Text(text) => self.write_text(&text)?,
            Event::SoftBreak => self.write(" ")?,
            Event::HardBreak => self.write("\\\n")?,
            Event::Code(code) => {
                // Inline code
                self.write("#raw(\"")?;
                let escaped = code.replace('\\', "\\\\").replace('"', "\\\"");
                self.write(&escaped)?;
                self.write("\")")?;
            }
            _ => {
                // Ignore other events that we don't support
            }
        }
        Ok(())
    }

    /// Handle the start of a tag.
    fn start_tag(&mut self, tag: Tag<'_>) -> Result<(), std::fmt::Error> {
        match tag {
            Tag::Paragraph => {
                self.ensure_newline()?;
                // In Typst, paragraphs are implicit, just ensure proper spacing
            }
            Tag::Heading { level, .. } => {
                self.ensure_newline()?;
                // Use Typst heading syntax with = signs
                let heading_marker = "=".repeat(level as usize);
                self.write(&heading_marker)?;
                self.write(" ")?;
            }
            Tag::List(_start_num) => {
                self.ensure_newline()?;
                self.list_level += 1;
                // Lists in Typst don't need explicit start tags
            }
            Tag::Item => {
                // Generate appropriate list marker based on nesting level and list type
                let indent = "  ".repeat(self.list_level.saturating_sub(1));
                self.write(&indent)?;
                if self.list_level % 2 == 1 {
                    self.write("- ")?; // Use bullet for odd levels
                } else {
                    self.write("+ ")?; // Use numbered for even levels  
                }
            }
            Tag::Emphasis => {
                self.write("_")?;
            }
            Tag::Strong => {
                self.write("*")?;
            }
            Tag::Strikethrough => {
                self.write("#strike[")?;
            }
            Tag::Link { dest_url, .. } => {
                self.write("#link(\"")?;
                self.write_escaped_url(&dest_url)?;
                self.write("\")[")?;
            }
            _ => {
                // Ignore unsupported tags
            }
        }
        Ok(())
    }

    /// Handle the end of a tag.
    fn end_tag(&mut self, tag_end: TagEnd) -> Result<(), std::fmt::Error> {
        match tag_end {
            TagEnd::Paragraph => {
                self.write("\n\n")?;
            }
            TagEnd::Heading(_) => {
                self.write("\n\n")?;
            }
            TagEnd::List(_) => {
                self.list_level = self.list_level.saturating_sub(1);
                if self.list_level == 0 {
                    self.write("\n")?;
                }
            }
            TagEnd::Item => {
                self.write("\n")?;
            }
            TagEnd::Emphasis => {
                self.write("_")?;
            }
            TagEnd::Strong => {
                self.write("*")?;
            }
            TagEnd::Strikethrough => {
                self.write("]")?;
            }
            TagEnd::Link => {
                self.write("]")?;
            }
            _ => {
                // Ignore unsupported tag ends
            }
        }
        Ok(())
    }

    /// Write text, escaping special Typst characters.
    fn write_text(&mut self, text: &str) -> Result<(), std::fmt::Error> {
        let escaped = escape_typst(text);
        self.write(&escaped)
    }

    /// Write URL, escaping for Typst string literals.
    fn write_escaped_url(&mut self, url: &str) -> Result<(), std::fmt::Error> {
        // Escape quotes and backslashes for Typst string literals
        let escaped = url.replace('\\', "\\\\").replace('"', "\\\"");
        self.write(&escaped)
    }
}

/// Escape special characters for Typst.
fn escape_typst(text: &str) -> String {
    text.replace('\\', "\\\\")
        .replace('*', "\\*")
        .replace('_', "\\_")
        .replace('#', "\\#")
        .replace('<', "\\<")
        .replace('>', "\\>")
        .replace('@', "\\@")
        .replace('$', "\\$")
        .replace('`', "\\`")
}

/// Convert a Markdown string to Typst format.
///
/// # Examples
///
/// ```
/// use tonguetoquill_typst_writer::markdown_to_typst;
///
/// let markdown = "This is *bold* and _italic_ text with a [link](https://example.com).";
/// let typst = markdown_to_typst(markdown);
/// println!("{}", typst);
/// ```
pub fn markdown_to_typst(markdown: &str) -> String {
    use pulldown_cmark::{Parser, Options};
    
    let mut options = Options::empty();
    options.insert(Options::ENABLE_STRIKETHROUGH);
    
    let parser = Parser::new_ext(markdown, options);
    let mut output = String::new();
    let writer = TypstWriter::new(&mut output);
    writer.run(parser).expect("writing to String should not fail");
    output
}

#[cfg(test)]
mod tests {
    use super::*;
    use pulldown_cmark::{Parser, Options};

    fn convert_markdown(input: &str) -> String {
        use pulldown_cmark::{Parser, Options};
        
        let mut options = Options::empty();
        options.insert(Options::ENABLE_STRIKETHROUGH);
        
        let parser = Parser::new_ext(input, options);
        let mut output = String::new();
        let writer = TypstWriter::new(&mut output);
        writer.run(parser).unwrap();
        output
    }

    #[test]
    fn test_simple_paragraph() {
        let input = "Hello world!";
        let output = convert_markdown(input);
        assert_eq!(output.trim(), "Hello world!");
    }

    #[test]
    fn test_emphasis() {
        let input = "This is _italic_ text.";
        let output = convert_markdown(input);
        assert!(output.contains("_italic_"));
    }

    #[test]
    fn test_strong() {
        let input = "This is **bold** text.";
        let output = convert_markdown(input);
        assert!(output.contains("*bold*"));
    }

    #[test]
    fn test_link() {
        let input = "Check out [this link](https://example.com).";
        let output = convert_markdown(input);
        assert!(output.contains("#link(\"https://example.com\")[this link]"));
    }

    #[test]
    fn test_simple_list() {
        let input = "- Item 1\n- Item 2\n- Item 3";
        let output = convert_markdown(input);
        assert!(output.contains("- Item 1"));
        assert!(output.contains("- Item 2"));
        assert!(output.contains("- Item 3"));
    }

    #[test]
    fn test_nested_list() {
        let input = "- Item 1\n  - Nested item\n- Item 2";
        let output = convert_markdown(input);
        assert!(output.contains("- Item 1"));
        assert!(output.contains("  + Nested item"));
        assert!(output.contains("- Item 2"));
    }

    #[test]
    fn test_escaping() {
        let input = "Text with *special* #characters and $math$.";
        let output = convert_markdown(input);
        // The asterisks around "special" should be handled as emphasis
        assert!(output.contains("\\#characters"));
        assert!(output.contains("\\$math\\$"));
    }

    #[test]
    fn test_headings() {
        let input = "# Heading 1\n\n## Heading 2\n\n### Heading 3";
        let output = convert_markdown(input);
        assert!(output.contains("= Heading 1"));
        assert!(output.contains("== Heading 2"));
        assert!(output.contains("=== Heading 3"));
    }

    #[test]
    fn test_strikethrough() {
        let input = "This text has ~~strikethrough~~ formatting.";
        let output = convert_markdown(input);
        assert!(output.contains("#strike[strikethrough]"));
    }

    #[test]
    fn test_inline_code() {
        let input = "Use the `print()` function.";
        let output = convert_markdown(input);
        assert!(output.contains("#raw(\"print()\")"));
    }

    #[test]
    fn test_code_escaping() {
        let input = r#"Use `"quotes"` and `\backslashes`."#;
        let output = convert_markdown(input);
        assert!(output.contains(r#"#raw("\"quotes\"")"#));
        assert!(output.contains(r#"#raw("\\backslashes")"#));
    }
}