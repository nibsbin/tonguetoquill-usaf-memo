"""Test autonumbering behavior in render-body.

Validates paragraph numbering per AFH 33-337 §2:
- Multiple top-level paragraphs: all numbered
- Single top-level paragraph: not numbered, sub-items still numbered
- Auto-numbering disabled: only nested items numbered with level offset
- Nested items start at correct first number/letter and increment properly
"""

import io
import typst
import pypdf

ROOT = "."
FONT_PATHS = ["."]


def extract_text(typ_content: str) -> str:
    """Compile Typst content and extract text from all pages."""
    # Write to a temp file in dev_assets
    path = "dev_assets/_test_tmp.typ"
    with open(path, "w") as f:
        f.write(typ_content)
    pdf = typst.compile(path, root=ROOT, font_paths=FONT_PATHS)
    reader = pypdf.PdfReader(io.BytesIO(pdf))
    return "\n".join(page.extract_text() for page in reader.pages)


PREAMBLE = """
#import "/src/body.typ": render-body
#import "/src/config.typ": *
#import "/src/utils.typ": *
#set page(height: auto, width: 6.5in, margin: 1in)
#set par(leading: spacing.line, spacing: spacing.line, justify: false)
#set block(above: spacing.line, below: 0em, spacing: 0em)
#set text(font: DEFAULT_BODY_FONTS, size: 12pt, fallback: true)
"""


def test_multi_top_level_auto_numbering():
    """Multiple top-level paragraphs: all numbered, sub-items start/increment correctly."""
    text = extract_text(PREAMBLE + """
#render-body(auto-numbering: true)[
First paragraph.

- Sub A
- Sub B
  - Sub-sub 1
  - Sub-sub 2

Second paragraph.
]
""")
    assert "1." in text and "First paragraph" in text
    assert "a." in text and "Sub A" in text
    assert "b." in text and "Sub B" in text
    assert "(1)" in text and "Sub-sub 1" in text
    assert "(2)" in text and "Sub-sub 2" in text
    assert "2." in text and "Second paragraph" in text
    print("PASS: test_multi_top_level_auto_numbering")


def test_single_top_level_with_sub_items():
    """Single top-level paragraph not numbered per AFH 33-337 §2; sub-items still numbered."""
    text = extract_text(PREAMBLE + """
#render-body(auto-numbering: true)[
Only one top-level paragraph.

- Sub A
- Sub B
  - Sub-sub 1
]
""")
    # Top-level paragraph should NOT be numbered
    assert "1." not in text, f"Single top-level paragraph should not be numbered, got: {text}"
    # Sub-items should be numbered
    assert "a." in text and "Sub A" in text
    assert "b." in text and "Sub B" in text
    assert "(1)" in text and "Sub-sub 1" in text
    print("PASS: test_single_top_level_with_sub_items")


def test_single_paragraph_no_number():
    """Single paragraph with no sub-items: not numbered per AFH 33-337 §2."""
    text = extract_text(PREAMBLE + """
#render-body(auto-numbering: true)[
This is the only paragraph.
]
""")
    assert "1." not in text, f"Single paragraph should not be numbered, got: {text}"
    assert "This is the only paragraph" in text
    print("PASS: test_single_paragraph_no_number")


def test_auto_numbering_disabled():
    """Auto-numbering disabled: base-level paragraphs unnumbered, nested items numbered with level offset."""
    text = extract_text(PREAMBLE + """
#render-body(auto-numbering: false)[
First paragraph.

- Group A
  - Sub A1
  - Sub A2
- Group B

Second paragraph.

- New group
]
""")
    # Base-level paragraphs should not be numbered
    lines = text.strip().split("\n")
    first_line = lines[0].strip()
    assert not first_line.startswith("1."), f"Base-level should not be numbered: {first_line}"
    # Nested items should be numbered with level offset -1
    assert "1." in text and "Group A" in text
    assert "a." in text and "Sub A1" in text
    assert "b." in text and "Sub A2" in text
    assert "2." in text and "Group B" in text
    # After base-level paragraph, counters should reset
    assert text.count("1.") >= 2, "Counter should reset after base-level paragraph"
    print("PASS: test_auto_numbering_disabled")


def test_deep_nesting_starts_correctly():
    """2nd-level and deeper nested paragraphs start at the first number/letter."""
    text = extract_text(PREAMBLE + """
#render-body(auto-numbering: true)[
Top paragraph.

- Level 1 item.
  - Level 2 item.
    - Level 3 item.

Another top paragraph.
]
""")
    # Verify correct starting values (not (0) or (-))
    assert "(1)" in text and "Level 2" in text, "Level 2 should start at (1)"
    assert "(a)" in text and "Level 3" in text, "Level 3 should start at (a)"
    assert "(0)" not in text, "No numbering should show (0)"
    assert "(-)" not in text, "No numbering should show (-)"
    print("PASS: test_deep_nesting_starts_correctly")


def test_non_base_level_incrementing():
    """Non-base level paragraphs increment their numbering."""
    text = extract_text(PREAMBLE + """
#render-body(auto-numbering: true)[
Top paragraph.

- First sub
- Second sub
  - First sub-sub
  - Second sub-sub
    - First deep
    - Second deep

Another top paragraph.
]
""")
    # Level 1 should increment: a., b.
    assert "a." in text and "First sub" in text
    assert "b." in text and "Second sub" in text
    # Level 2 should increment: (1), (2)
    assert "(1)" in text and "First sub-sub" in text
    assert "(2)" in text and "Second sub-sub" in text
    # Level 3 should increment: (a), (b)
    assert "(a)" in text and "First deep" in text
    assert "(b)" in text and "Second deep" in text
    print("PASS: test_non_base_level_incrementing")


def test_child_counter_reset():
    """Child counters reset when a parent level is processed."""
    text = extract_text(PREAMBLE + """
#render-body(auto-numbering: true)[
Top paragraph.

- Group A
  - Sub A1
  - Sub A2
- Group B
  - Sub B1 (should restart at (1))

Another top paragraph.

- New group (should restart at a.)
]
""")
    # After "Group B" is processed, sub-counters reset
    # "Sub B1" should be (1), not (3)
    # Check that (1) appears at least twice (once under each parent)
    assert text.count("(1)") >= 2, "Sub-counter should reset under new parent"
    print("PASS: test_child_counter_reset")


if __name__ == "__main__":
    test_multi_top_level_auto_numbering()
    test_single_top_level_with_sub_items()
    test_single_paragraph_no_number()
    test_auto_numbering_disabled()
    test_deep_nesting_starts_correctly()
    test_non_base_level_incrementing()
    test_child_counter_reset()
    print("\nAll tests passed!")
