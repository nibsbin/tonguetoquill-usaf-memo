# USAF Memo Template for Typst

A comprehensive Typst template for creating official United States Air Force memorandums that comply with AFH 33-337 "The Tongue and Quill" formatting standards.

## Features

- **Automatic formatting compliance** with AFH 33-337 standards
- **Hierarchical paragraph numbering** (1., a., (1), (a)) with proper indentation
- **Smart page break handling** for closing sections with continuation formatting
- **Professional typography** with Times New Roman font and proper spacing
- **Complete letterhead automation** including DoD seal placement and scaling
- **Flexible content management** for various memo types
- **Proper signature block positioning** and closing elements
- **Intelligent space management** prevents orphaned headers and improper splits

## Quick Start

### Installation

```bash
# Clone the repository
git clone https://github.com/SnpM/typst-usaf-memo.git
cd typst-usaf-memo

# Compile the example (note: --root flag is required for templates that reference the root)
typst compile lib.typ --root .
```

### Basic Usage

```typst
#import "lib.typ": *

#OfficialMemorandum(
  letterhead-title: "DEPARTMENT OF THE AIR FORCE",
  letterhead-caption: "YOUR ORGANIZATION",
  memo-for: "RECIPIENT ORG/SYMBOL",
  from-block: (
    "YOUR-ORG/SYMBOL",
    "Your Organization Name",
    "Street Address",
    "City ST 12345-6789"
  ),
  subject: "Your Memo Subject",
  signature-block: (
    "FIRST M. LAST, Rank, USAF",
    "Your Title",
    "Your Organization"
  )
)[
  // Your memo content goes here
  This is the main body of your memorandum.
  
  #sub-par[This is a first-level subparagraph with automatic numbering.]
  
  #sub-sub-par[This is a second-level subparagraph.]
]
```

## Template Parameters

### Required Parameters

- **letterhead-title**: Organization title (e.g., "DEPARTMENT OF THE AIR FORCE")
- **letterhead-caption**: Sub-organization (e.g., "42D OPERATIONS SQUADRON")  
- **memo-for**: Recipient designation (can be string, array, or nested array for grid layout)
- **from-block**: Sender information as array of strings
- **subject**: Memo subject line
- **signature-block**: Array of signature lines
- **body**: Main memo content (positional parameter)

### Optional Parameters

- **letterhead-seal**: Path to organization seal image (default: "assets/dod_seal.png")
- **references**: Array of reference documents  
- **attachments**: Array of attachment descriptions
- **cc**: Array of courtesy copy recipients
- **distribution**: Array of distribution list entries
- **indorsements**: Array of `Indorsement` objects for memo endorsements
- **letterhead_font**: Font for letterhead (default: "Arial")
- **body_font**: Font for body text (default: "Times New Roman")
- **par_block_indent**: Enable paragraph block indentation (default: false)
- **pagebreak_closing**: Force page break before closing sections (default: false)

### Complete Examples

For comprehensive examples with all parameters, see:
- **Standard Air Force memo**: `template/usaf-memo.typ` - Shows proper formatting with references, attachments, cc, distribution, and indorsements
- **Custom organization memo**: `template/starkindustries.typ` - Demonstrates custom letterhead and extensive use of all optional parameters

To view these examples:
```bash
typst compile template/usaf-memo.typ --root .
typst compile template/starkindustries.typ --root .
```

## Paragraph Numbering

The template provides automatic hierarchical paragraph numbering following AFH 33-337 standards:

```typst
// Regular paragraphs are automatically numbered as 1., 2., 3., etc.
This is a regular paragraph.

Another regular paragraph.

#sub-par[First-level subparagraphs are numbered a., b., c., etc.]

#sub-sub-par[Second-level subparagraphs are numbered (1), (2), (3), etc.]

#sub-sub-sub-par[Third-level subparagraphs are numbered (a), (b), (c), etc.]
```

## Smart Page Break Handling

The template automatically manages page breaks for closing sections according to AFH 33-337 standards:

- **Attachments**: "Do not divide attachment listings between two pages"
- **Distribution**: "Do not divide distribution lists between two pages"
- **CC sections**: Consistent handling with other sections

### How It Works

1. **Content measurement**: Calculates if section fits on current page
2. **Automatic continuation**: Shows "(listed on next page)" when needed
3. **Clean breaks**: Moves entire sections to avoid orphaned headers
4. **Compliant formatting**: Follows exact AFH 33-337 continuation requirements

Example output:
```
Attachments (listed on next page):
[page break]
Attachments:
1. Document A
2. Document B
```

## Document Structure

The template automatically handles:

1. **Page setup**: US Letter size with 1-inch margins
2. **Typography**: 12pt Times New Roman font with proper line spacing
3. **Header elements**: DoD seal (scaled to 1in × 2in), letterhead, and date positioning
4. **Body formatting**: Justified text with proper paragraph spacing and numbering
5. **Signature block**: Positioned 4.5 inches from left edge
6. **Closing elements**: Attachments, cc, and distribution lists with smart page breaks
7. **Page numbering**: Starts on page 2, positioned 0.5" from top, flush right
8. **Continuation handling**: Proper "(listed on next page)" formatting for long sections

## Examples

The `template/` directory contains sample memorandums demonstrating various use cases:

- **usaf-memo.typ**: Standard Air Force memorandum template
- **ussf-memo.typ**: Space Force memorandum variant
- **starkindustries.typ**: A humorous memo featuring Iron Man regulatory compliance issues

To compile an example:

```bash
typst compile template/usaf-memo.typ --root .
```

**Note**: The `--root .` flag is required when compiling templates that reference files from the root directory.

## Compilation

When compiling templates that reference files from the root directory (such as the main library file `lib.typ`), you must use the `--root` flag:

```bash
# Compile any template file
typst compile template/usaf-memo.typ --root .
typst compile template/ussf-memo.typ --root .
typst compile template/starkindustries.typ --root .
```

The `--root .` flag tells Typst to treat the current directory as the root for resolving file imports, which is necessary for the templates to correctly find and import the main library file.

## Requirements

- **Typst**: Version 0.13.0 or higher
- **Assets**: The `assets/dod_seal.png` file must be accessible for the DoD seal
- **Fonts**: Times New Roman font (typically pre-installed on most systems)

## File Structure

```
typst-usaf-memo/
├── lib.typ              # Main template file
├── assets/
│   ├── dod_seal.png     # Department of Defense seal
│   └── starkindustries_seal.png  # Example organization seal
├── template/
│   ├── usaf-memo.typ    # Standard USAF memo template
│   ├── ussf-memo.typ    # Space Force memo template
│   └── starkindustries.typ  # Example memo with custom branding
├── docs/
│   └── afh33-337_chapter14  # AFH 33-337 Chapter 14 reference
├── README.md           # This file
└── LICENSE             # License information
```

## Formatting Standards

This template implements the following AFH 33-337 requirements:

- **Margins**: 1 inch on all sides
- **Font**: Times New Roman, 12 point
- **Line spacing**: Proper spacing between elements
- **Paragraph numbering**: Standard Air Force hierarchy with automatic indentation
- **Date format**: Right-aligned, spelled out format
- **Signature block**: Positioned according to regulations
- **Page numbering**: Starts page 2, top right, 0.5" from edge
- **DoD seal**: Scaled to fit 1in × 2in box while preserving aspect ratio
- **Page breaks**: Smart handling of closing sections with continuation formatting
- **Orphan prevention**: No isolated section headers or improper splits

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests to improve the template.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

Assets used in this project:

- `assets/dod_seal.png` is [public domain](https://commons.wikimedia.org/wiki/File:Seal_of_the_United_States_Department_of_Defense_(2001%E2%80%932022).svg).

- `assets/starkindustries_seal.png` is [public domain](https://commons.wikimedia.org/wiki/File:Stark_Industries.png).

## Author

Created by [Nibs](https://github.com/snpm)
