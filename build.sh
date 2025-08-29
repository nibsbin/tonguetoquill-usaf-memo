#!/bin/bash

# Build all .typ files to corresponding PDFs

echo "Compiling templates and tests to PDFs..."

typst compile --root . lib.typ pdfs/lib.pdf
typst compile --root . template/guide.typ pdfs/guide.pdf
typst compile --root . template/starkindustries.typ pdfs/starkindustries.pdf
typst compile --root . template/usaf-template.typ pdfs/usaf-template.pdf
typst compile --root . template/ussf-template.typ pdfs/ussf-template.pdf
typst compile --root . tests/test-indorsements.typ tests/test-indorsements.pdf

echo "All compilations completed."
