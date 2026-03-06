#import "/src/lib.typ": frontmatter, mainmatter, backmatter

#show: frontmatter.with(
  subject: "Test Multi-Block List Items",
  memo_for: "TEST/CC",
  memo_from: "TEST/DO",
)

#show: mainmatter

This is the first paragraph.

+ This is the first paragraph of list item one.

  This is a CONTINUATION paragraph still part of list item one. It should NOT get its own number.

+ This is list item two.

This is the closing paragraph.
