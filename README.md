# USAF Memo Template for Typst

A comprehensive Typst template for creating official United States Air Force memorandums that comply with AFH 33-337 "The Tongue and Quill" formatting standards.

## Features

- **Automatic formatting compliance** with AFH 33-337 standards
- **Hierarchical paragraph numbering** (1., a., (1), (a))
- **Professional typography** with Times New Roman font and proper spacing
- **Complete letterhead automation** including DoD seal placement
- **Flexible content management** for various memo types
- **Proper signature block positioning** and closing elements

## Quick Start

### Installation

```bash
# Clone the repository
git clone https://github.com/SnpM/typst-usaf-memo.git
cd typst-usaf-memo

# Compile the example
typst compile lib.typ
```

### Basic Usage

```typst
#import "lib.typ": *

#usaf-memo(
  letterhead-title: "DEPARTMENT OF THE AIR FORCE",
  letterhead-caption: "YOUR ORGANIZATION",
  memo-for: "RECIPIENT ORG/SYMBOL",
  from-block: [
    YOUR-ORG/SYMBOL\
    Your Organization Name\
    Street Address\
    City ST 12345-6789
  ],
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
- **memo-for**: Recipient designation
- **from-block**: Sender information block
- **subject**: Memo subject line
- **signature-block**: Array of signature lines
- **body**: Main memo content (positional parameter)

### Optional Parameters

- **references**: Array of reference documents
- **attachments**: Array of attachment descriptions  
- **cc**: Courtesy copy recipients
- **distribution**: Distribution list

### Example with All Parameters

```typst
#usaf-memo(
  letterhead-title: "DEPARTMENT OF THE AIR FORCE",
  letterhead-caption: "42D OPERATIONS SQUADRON (AETC)",
  memo-for: "ALL SQUADRON PERSONNEL",
  from-block: [
    42 OPS/CC\
    42d Operations Squadron\
    50 LeMay Plaza South\
    Maxwell AFB AL 36112-6334
  ],
  subject: "Updated Safety Procedures",
  references: (
    "AFI 91-202, 8 Aug 2020, The US Air Force Mishap Prevention Program",
    "AFMAN 91-203, 6 July 2018, Air Force Occupational Safety, Fire, and Health Standards"
  ),
  signature-block: (
    "JOHN A. SMITH, Colonel, USAF",
    "Commander",
    "42d Operations Squadron"
  ),
  attachments: (
    "Safety Checklist, Updated Procedures",
    "Emergency Contact Information"
  ),
  cc: [
    42 ABW/CC\
    42 MSG/CC
  ],
  distribution: [
    HQ AETC/A3\
    All Flight Commanders\
    Safety Office
  ]
)[
  // Memo content here
]
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

## Document Structure

The template automatically handles:

1. **Page setup**: US Letter size with 1-inch margins
2. **Typography**: 12pt Times New Roman font with proper line spacing
3. **Header elements**: DoD seal, letterhead, and date positioning
4. **Body formatting**: Justified text with proper paragraph spacing
5. **Signature block**: Positioned 4.5 inches from left edge
6. **Closing elements**: Attachments, cc, and distribution lists
7. **Page numbering**: Starts on page 2, positioned 0.5" from top, flush right

## Examples

The `examples/` directory contains sample memorandums demonstrating various use cases:

- **starkindustries.typ**: A humorous memo featuring Iron Man regulatory compliance issues

To compile an example:

```bash
typst compile examples/starkindustries.typ --root .
```

## Requirements

- **Typst**: Version 0.13.0 or higher
- **Assets**: The `assets/dod_seal.png` file must be accessible for the DoD seal

## File Structure

```
typst-usaf-memo/
├── lib.typ              # Main template file
├── assets/
│   └── dod_seal.png     # Department of Defense seal
├── examples/
│   └── starkindustries.typ  # Example memo
├── docs/                # Documentation
├── README.md           # This file
└── LICENSE             # License information
```

## Formatting Standards

This template implements the following AFH 33-337 requirements:

- **Margins**: 1 inch on all sides
- **Font**: Times New Roman, 12 point
- **Line spacing**: Proper spacing between elements
- **Paragraph numbering**: Standard Air Force hierarchy
- **Date format**: Right-aligned, spelled out format
- **Signature block**: Positioned according to regulations
- **Page numbering**: Starts page 2, top right, 0.5" from edge

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests to improve the template.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

Created by [Nibs](https://github.com/snpm)
