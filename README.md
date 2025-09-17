

# tonguetoquill: USAF Memo Template for Typst


[![github-repository](https://img.shields.io/badge/GitHub-Repository-blue?logo=github)](https://github.com/SnpM/tonguetoquill-usaf-memo)
[![Nibs](https://img.shields.io/badge/author-Nibs-white?logo=github)](https://github.com/SnpM)

[![typst-universe](https://img.shields.io/badge/Typst-Universe-aqua)](
https://github.com/snpm/tonguetoquill-usaf-memo)

A comprehensive Typst template for creating official United States Air Force memorandums that comply with AFH 33-337 "The Tongue and Quill" formatting standards.

## Features

### Core Formatting
- **Full AFH 33-337 compliance** with "The Tongue and Quill" formatting standards
- **Automatic letterhead generation** with configurable organization title, caption, and seal
- **Professional typography** using Times New Roman font family with proper sizing (12pt body text)
- **Standard military date format** (e.g., "1 January 2024") with automatic today() default
- **Proper page margins** (1 inch on all sides) and consistent spacing throughout

### Advanced Paragraph System
- **Hierarchical paragraph numbering** (1., a., (1), (a)) with proper indentation
- **Automatic counter management** for nested paragraph structures
- **AFH 33-337 compliant numbering** following military correspondence standards
- **Smart indentation** with precise tab stop alignment
- **Enum-based interface** using Typst's native list system for intuitive authoring

### Document Structure
- **Complete header automation** (MEMORANDUM FOR, FROM, SUBJECT, References)
- **Flexible recipient handling** with multi-column grid layout support
- **Optional reference section** with lettered formatting (a), (b), (c)
- **Professional signature blocks** with proper positioning and orphan prevention
- **Comprehensive backmatter** (Attachments, CC, Distribution) with smart formatting

### Smart Page Management
- **Intelligent page breaks** preventing orphaned headers and signature blocks
- **Continuation formatting** for multi-page backmatter sections
- **Dynamic spacing calculations** to maintain proper document flow
- **Page numbering** starting from page 2 per AFH 33-337 standards
- **Orphan/widow prevention** for professional document appearance

### Indorsement System
- **Sequential indorsement numbering** (1st Ind, 2d Ind, 3d Ind) following military conventions
- **Flexible indorsement formats** supporting both same-page and separate-page styles
- **Automatic date and subject referencing** linking back to original memorandum
- **Individual signature blocks** and backmatter for each indorsement
- **Smart page break control** for proper document flow

### Customization Options
- **Configurable fonts** with automatic fallbacks (Copperplate CC for letterhead, Times New Roman/TeX Gyre Termes for body)
- **Organization seal support** with automatic scaling and positioning
- **Flexible styling parameters** for various organizational needs
- **Multi-column recipient layouts** with configurable column counts
- **Optional paragraph indentation** styles (block vs. hanging indent)

## Quick Start

### Typst.app (Easiest)

1. Go to [the package page](https://typst.app/universe/package/tonguetoquill-usaf-memo) and click "Create project in app".

2. Download the [*CopperplateCC-Heavy*](https://github.com/SnpM/tonguetoquill-usaf-memo/blob/bebba4c1a51f9d67ca66e08109439b2c637e1015/template/assets/fonts/CopperplateCC-Heavy.otf) font and upload it to your project folder. This is an open-source clone of *Copperplate Gothic Bold*.
    - **Note:** *Times New Roman* is a proprietary Microsoft font that I can't distribute legally. The package will automatically use the built-in *TeX Gyre Termes* font, an open-source clone of *Times New Roman*.

3. Start with one of the template files:
   - `template/usaf-template.typ` for a standard Air Force memo
   - `template/ussf-template.typ` for Space Force
   - `template/content-guide.typ` for a comprehensive example

### Local Installation

1. [Install Typst](https://github.com/typst/typst?tab=readme-ov-file#installation).

2. Initialize template from Typst Universe:
```bash
typst init @preview/tonguetoquill-usaf-memo:0.1.0 my-memo
cd my-memo
```

3. Download the required font:
```bash
# Download CopperplateCC-Heavy font
curl -L -o CopperplateCC-Heavy.otf https://github.com/SnpM/tonguetoquill-usaf-memo/raw/bebba4c1a51f9d67ca66e08109439b2c637e1015/template/assets/fonts/CopperplateCC-Heavy.otf
```

4. Compile a template file:
```bash
typst compile --font-path . template/usaf-template.typ my-memo.pdf
```

### Local Development

Clone [the repo](https://github.com/SnpM/tonguetoquill-usaf-memo) and follow [these instructions](https://github.com/typst/packages/tree/main?tab=readme-ov-file#local-packages) to install the package locally for development.

```bash
git clone https://github.com/SnpM/tonguetoquill-usaf-memo.git
cd tonguetoquill-usaf-memo
./build.sh  # Compile all examples (requires Typst installed)
```

### Basic Usage

Import the core functions for creating memorandums:

```typst
#import "@preview/tonguetoquill-usaf-memo:0.1.0": official-memorandum, indorsement
```

**Minimal Example:**
```typst
#official-memorandum(
  subject: "Your Subject Here",
)[
Your memorandum content goes here.

+ Use plus signs for numbered subparagraphs.
  + Indent with spaces for deeper nesting.

Continue with regular paragraphs.
]
```

See the [API Reference](#api-reference) section below for complete parameter documentation.

### Complete Examples

For comprehensive examples with all parameters, see:
- **Guide**: `template/content-guide.typ` - Comprehensive guide showing all parameters and features with enum-based paragraph system
- **Standard Air Force memo**: `template/usaf-template.typ` - Shows proper formatting with references, attachments, cc, distribution, and indorsements
- **Space Force memo**: `template/ussf-template.typ` - Space Force memorandum variant with proper formatting
- **Custom organization memo**: `template/starkindustries.typ` - Demonstrates custom letterhead and extensive use of all optional parameters

## Additional usage details

### Paragraph numbering

AFH 33-337–compliant hierarchical numbering using Typst's native enum lists.

```typst
Base paragraph numbered as 1., 2., etc.

+ Level 1 subparagraph lettered as a., b., etc.
  + Level 2 subparagraph numbered as (1), (2), etc.
    + Level 3 subparagraph lettered as (a), (b), etc.

This returns to base paragraph numbering as 2.
```

### Tips
- Base-level paragraphs are plain text lines; do not prefix them with `+`.
- Increase depth by adding leading spaces before `+` (two spaces per level works well).
- Keep items contiguous—an empty line ends the list and returns to the base level.
- Indentation and alignment are handled for you; subparagraphs align with proper tab stops.
- Numbering and spacing are automatic and AFH 33-337 compliant.

### Common pitfalls
- Using `-` or `*` instead of `+` creates a bullet list, not a numbered enum.
- Misaligned nesting: ensure nested `+` items are indented more than their parent.

### Sentence spacing

The project includes GitHub Copilot prompts in `.github/prompts/` to help with sentence spacing formatting:

- **double-space-sentence.prompt.md**: Converts single spaces after sentences to double spaces (`~ `) within memo content
- **single-space-sentence.prompt.md**: Converts double spaces back to single spaces within memo content

These prompts help ensure consistent spacing formatting in your memorandums according to your organization's preferred style.

### Smart page break handling

The template automatically manages page breaks for closing sections according to AFH 33-337 standards:

- **Attachments**: "Do not divide attachment listings between two pages"
- **Distribution**: "Do not divide distribution lists between two pages"
- **CC sections**: Consistent handling with other sections

## API Reference

### Core Functions

#### `official-memorandum(...)`

Creates an official memorandum following AFH 33-337 "The Tongue and Quill" standards.

**Required Parameters:**
- `subject`: Memorandum subject line (must be descriptive and in title case)
- `body`: Main memorandum content (use enums for numbered paragraphs)

**Key Parameters:**
```typst
official-memorandum(
  letterhead-title: "DEPARTMENT OF THE AIR FORCE",           // Organization title
  letterhead-caption: "[YOUR SQUADRON/UNIT NAME]",           // Sub-organization
  letterhead-seal: none,                                     // Organization seal image
  date: none,                                                // Date (defaults to today)
  memo-for: ("[OFFICE1]", "[OFFICE2]"),                     // Recipients array
  memo-from: ("[YOUR/SYMBOL]", "[Organization]", "[Address]"), // Sender info array
  subject: "[Your Subject in Title Case - Required]",        // Subject line
  references: ("AFI 123-45", "AFMAN 67-89"),                // Optional references
  signature-block: ("[NAME, Rank, USAF]", "[Title]"),       // Signature lines
  attachments: ("Attachment 1", "Attachment 2"),             // Optional attachments
  cc: ("[OFFICE/SYMBOL]",),                                 // Courtesy copies
  distribution: ("[OFFICE]",),                              // Distribution list
  indorsements: (indorsement(...),),                        // Optional indorsements
  
  // Styling options
  letterhead-font: ("Copperplate CC",),                     // Letterhead fonts
  body-font: ("times new roman", "tex gyre termes"),        // Body fonts
  memo-for-cols: 3,                                         // Recipient columns
  paragraph-block-indent: false,                            // Paragraph indentation
  leading-backmatter-pagebreak: false,                      // Force page break
  
  // Document body content goes here
)[Your memorandum content with enum lists for numbered paragraphs]
```

#### `indorsement(...)`

Creates an indorsement for forwarding or commenting on a memorandum.

```typst
indorsement(
  office-symbol: "ORG/SYMBOL",                              // Sending organization
  memo-for: "RECIPIENT/SYMBOL",                             // Recipient organization
  signature-block: ("[NAME, Rank, USAF]", "[Title]"),      // Signature lines
  attachments: none,                                         // Optional attachments
  cc: none,                                                 // Courtesy copies
  leading-pagebreak: false,                                 // Force page break
  separate-page: false,                                     // Separate page format
  indorsement-date: datetime.today(),                       // Indorsement date
  
  // Indorsement body content
)[Your indorsement content]
```

### Paragraph Numbering System

Use Typst's native enum system for AFH 33-337 compliant paragraph numbering:

```typst
This is paragraph 1.

+ This is subparagraph 1a.
  + This is subparagraph 1a(1).
    + This is subparagraph 1a(1)(a).

+ This is subparagraph 1b.

This is paragraph 2.
```

**Numbering Hierarchy:**
- **Level 0**: 1., 2., 3., etc. (base paragraphs)
- **Level 1**: a., b., c., etc. (subparagraphs)
- **Level 2**: (1), (2), (3), etc. (sub-subparagraphs)
- **Level 3**: (a), (b), (c), etc. (sub-sub-subparagraphs)
- **Level 4+**: Underlined format for deeper nesting

### Font Configuration

The template supports configurable fonts with automatic fallbacks:

**Letterhead Fonts:**
- Primary: `"Copperplate CC"` (open-source Copperplate Gothic Bold clone)
- Fallback: System serif fonts

**Body Fonts:**
- Primary: `"times new roman"` (if available)
- Fallback: `"tex gyre termes"` (open-source Times New Roman clone)

### Smart Features

**Page Break Management:**
- Prevents orphaned signature blocks
- Smart backmatter section handling
- Continuation labeling for multi-page sections

**Automatic Formatting:**
- Military date format (1 January 2024)
- Proper spacing and indentation
- AFH 33-337 compliant typography
- Automatic paragraph numbering and indentation

## Troubleshooting

### Common Issues

**Missing Fonts:**
- Download [CopperplateCC-Heavy.otf](https://github.com/SnpM/tonguetoquill-usaf-memo/blob/bebba4c1a51f9d67ca66e08109439b2c637e1015/template/assets/fonts/CopperplateCC-Heavy.otf) for letterhead
- The template automatically falls back to TeX Gyre Termes for body text if Times New Roman is unavailable

**Paragraph Numbering Issues:**
- Use `+` for enum items, not `-` or `*`
- Maintain consistent indentation (2 spaces per level recommended)
- Keep enum items contiguous - empty lines reset to base level

**Build Errors:**
- Ensure Typst 0.13.1 or later is installed
- Check that all image files are accessible in the correct paths
- Verify font files are in the project directory for local compilation

### Performance Tips

- Use `leading-backmatter-pagebreak: true` for complex documents with extensive backmatter
- Keep indorsement content concise to avoid pagination issues
- Use `memo-for-cols` parameter to optimize recipient list layout

## Development

### Contributing

Contributions are welcome! Please follow these guidelines:

1. **Documentation**: Update both inline documentation and this README for any new features
2. **Testing**: Test your changes with the provided template files
3. **Standards**: Ensure AFH 33-337 compliance for any formatting changes
4. **Examples**: Add examples to demonstrate new functionality

### Local Development Setup

1. Clone the repository:
```bash
git clone https://github.com/SnpM/tonguetoquill-usaf-memo.git
cd tonguetoquill-usaf-memo
```

2. Install Typst locally following [official instructions](https://github.com/typst/typst?tab=readme-ov-file#installation)

3. Test compilation:
```bash
typst compile --font-path . template/usaf-template.typ test-output.pdf
```

4. Follow [Typst local package instructions](https://github.com/typst/packages/tree/main?tab=readme-ov-file#local-packages) for development

### Project Structure

```
├── src/
│   ├── lib.typ          # Main template functions
│   └── utils.typ        # Utility functions and helpers
├── template/
│   ├── *.typ           # Example template files
│   └── assets/         # Fonts and images
├── pdfs/               # Compiled example outputs
└── README.md           # This documentation
```

## Examples

The `template/` directory contains sample memorandums demonstrating various use cases:

### Template Files

- [**usaf-template.typ**](template/usaf-template.typ): Standard Air Force memorandum with all sections
- [**ussf-template.typ**](template/ussf-template.typ): Space Force memorandum variant
- [**starkindustries.typ**](template/starkindustries.typ): Corporate memo example (Pepper notifies Tony about Iron Man suit regulations)
- [**content-guide.typ**](template/content-guide.typ): Comprehensive guide showing all features with detailed examples

### Basic Memorandum Example

```typst
#import "@preview/tonguetoquill-usaf-memo:0.1.0": official-memorandum

#official-memorandum(
  letterhead-title: "DEPARTMENT OF THE AIR FORCE",
  letterhead-caption: "123RD FIGHTER SQUADRON",
  letterhead-seal: image("assets/dod_seal.gif"),
  
  memo-for: ("123 FW/CC", "123 OG/CC", "123 MXG/CC"),
  memo-from: (
    "123 FS/CC",
    "123rd Fighter Squadron",
    "Joint Base Example",
    "Example AFB ST 12345-6789"
  ),
  subject: "Example Official Memorandum Format",
  
  signature-block: (
    "JOHN A. SMITH, Lt Col, USAF",
    "Commander"
  ),
)[
This is the first paragraph of the memorandum body.

+ This is subparagraph 1a.
  + This is subparagraph 1a(1).
  + This is subparagraph 1a(2).

+ This is subparagraph 1b.

This is the second paragraph.
]
```

### Memorandum with Indorsements

```typst
#import "@preview/tonguetoquill-usaf-memo:0.1.0": official-memorandum, indorsement

#official-memorandum(
  // ... basic parameters ...
  indorsements: (
    indorsement(
      office-symbol: "123 OG/CC",
      memo-for: "123 FW/CC",
      signature-block: (
        "JANE B. DOE, Col, USAF",
        "Commander, 123rd Operations Group"
      ),
    )[
    I concur with the squadron commander's recommendation.
    ],
    
    indorsement(
      office-symbol: "123 FW/CC", 
      memo-for: "HAF/A3O",
      signature-block: (
        "ROBERT C. JONES, Brig Gen, USAF",
        "Commander"
      ),
    )[
    Forwarded with endorsement.
    ]
  ),
)[
Original memorandum content requesting approval for new training program.
]
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

External assets used in this project:

- `dod_seal.gif` is [public domain](https://www.e-publishing.af.mil/Portals/1/Documents/Official%20Memorandum%20Template_10Nov2020.dotx?ver=M7cny_cp1_QDajkyg0xWBw%3D%3D)
- `starkindustries_seal.png` is [public domain](https://commons.wikimedia.org/wiki/File:Stark_Industries.png).
- `Copperlate CC` is under [SIL Open Font License](./template/assets/fonts/LICENSE.md) pulled from [here](https://github.com/CowboyCollective/CopperplateCC)
- `TeX Gyre Termes` is under [GUST Font License](https://www.gust.org.pl/projects/e-foundry/tex-gyre/term) pulled from [here](https://www.fontsquirrel.com/fonts/tex-gyre-termes)