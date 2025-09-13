---
mode: edit
description: Double space sentences
model: GPT-4.1

---
Within my current file's OfficialMemorandum and Indorsement content blocks:

For every sentence-ending punctuation:
- Replace the single space after a period, question mark, or exclamation point (". ", "? ", "! ") with `~ `, except when the period is part of a common abbreviation (e.g., "e.g.", "i.e.", "Dr.", "Mr.", "Ms.", "Lt.", "Col.", "U.S.", "etc.").
- Do **not** replace the space after a semicolon ("; ").

Examples:
- "This is a sentence. This is another." → "This is a sentence.~ This is another."
- "Is this correct? Yes it is!" → "Is this correct?~ Yes it is!~"
- "This is Dr. Smith. He is here." → "This is Dr. Smith.~ He is here."
- "Use e.g. examples. Not all apply." → "Use e.g. examples.~ Not all apply."
- "This is a list; it has items." → "This is a list; it has items."
