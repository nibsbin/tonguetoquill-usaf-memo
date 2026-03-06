#import "/src/lib.typ": frontmatter, mainmatter, backmatter

#show: frontmatter.with(
  subject: "Debug Test",
  memo_for: "TEST/CC",
  memo_from: "TEST/DO",
)

#show: mainmatter

This is the first paragraph.

+ First list item paragraph one.

  First list item continuation.

+ Second list item.

This is the closing paragraph.
