#import "/src/lib.typ": frontmatter, mainmatter

#show: frontmatter.with(
  subject: "Spacing Regression",
  memo-for: (
    "TEST/CC",
    "TEST/CD",
  ),
  memo-from: (
    "TEST/DO",
    "123 Example Street",
    "Washington DC 12345",
  ),
  date: datetime(year: 2026, month: 3, day: 11),
)

#show: mainmatter

Alpha top paragraph.

+ Bravo child paragraph.

Charlie closing paragraph.
