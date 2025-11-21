#!/bin/bash

compile_template() {
  local template=$1
  local input="template/${template}.typ"
  local output="pdfs/${template}.pdf"

  echo "Compiling ${template}..."
  if typst compile --font-path . --root . "$input" "$output"; then
    echo "  ✓ Generated: $(pwd)/$output"
  else
    echo "  ✗ Failed to compile $template"
    return 1
  fi
}

echo "Building templates..."
echo

compile_template "starkindustries"
compile_template "usaf-template"
compile_template "ussf-template"

echo
echo "All compilations completed."
