#!/bin/bash

# Build all .typ files to corresponding PDFs
# Note that including the fallback fonts for windows/mac/web app creates warnings
# There is not current way to suppress these warnings

echo "Compiling templates and tests to PDFs..."
typst compile --font-path . template/starkindustries.typ pdfs/starkindustries.pdf
typst compile --font-path . tests/test-indorsements.typ tests/test-indorsements.pdf


# These template use a third party font included in the repository
typst compile --font-path . template/content-guide.typ pdfs/content-guide.pdf
typst compile --font-path . template/usaf-template.typ pdfs/usaf-template.pdf
typst compile --font-path . template/ussf-template.typ pdfs/ussf-template.pdf

echo "All compilations completed."
