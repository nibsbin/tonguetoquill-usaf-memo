#import "/src/lib.typ": backmatter, frontmatter, mainmatter

#show: frontmatter.with(
  letterhead_title: "STARK INDUSTRIES",
  letterhead_caption: "EXECUTIVE OFFICE",
  subject: "Test Numbering",
  memo_for: "MR. TONY STARK",
  memo_from: "STARK INDUSTRIES",
)

#show: mainmatter

Intro paragraph.

+ First item text.

  + Sub-item a.

  + Sub-item b.

  + Sub-item c.

+ Second item text.

  + Sub-item d.

  + Sub-item e.

Closing paragraph.
