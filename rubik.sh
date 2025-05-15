#!/bin/bash

# rubik.sh - Convert clipboard content using pandoc (default: markdown -> org)

# Help message
show_help() {
    cat <<EOF
Usage: ./rubik.sh [input_format] [output_format]

Description:
  Converts clipboard content using pandoc and replaces the clipboard with the result.
  - For binary output formats (e.g. docx), the result is written to a file.
  - For rich text output (e.g. html), HTML is placed in clipboard as formatted content.

Arguments:
  input_format     Input format for pandoc (default: markdown)
  output_format    Output format for pandoc (default: org)

Options:
  --help           Show this help message and exit
  --list-formats   Show all supported pandoc input/output formats

Examples:
  ./rubik.sh                # Markdown to Org (default)
  ./rubik.sh org markdown  # Org to Markdown
  ./rubik.sh markdown html # Markdown to formatted HTML clipboard
  ./rubik.sh markdown docx # Markdown to .docx file

EOF
}

# List all pandoc-supported formats
list_formats() {
    echo "Supported input formats:"
    pandoc --list-input-formats | column
    echo
    echo "Supported output formats:"
    pandoc --list-output-formats | column
}

# Handle flags
case "$1" in
    --help)
        show_help
        exit 0
        ;;
    --list-formats)
        list_formats
        exit 0
        ;;
esac

# Default formats
input_format="${1:-markdown}"
output_format="${2:-org}"

# Read from clipboard
clipboard_content=$(xclip -selection clipboard -o 2>/dev/null)

if [[ -z "$clipboard_content" ]]; then
    echo "Error: Clipboard is empty or inaccessible."
    exit 1
fi

# Binary formats must be saved to file
binary_formats=("docx" "pdf" "odt" "epub" "pptx")
if [[ " ${binary_formats[*]} " =~ " $output_format " ]]; then
    tmpfile=$(mktemp --suffix=".$output_format")
    echo "$clipboard_content" | pandoc -f "$input_format" -t "$output_format" -o "$tmpfile"
    echo "Binary format '$output_format' written to: $tmpfile"
    echo "Copy or open the file manually as needed."
    exit 0
fi

# HTML gets pushed to clipboard as rich text
if [[ "$output_format" == "html" ]]; then
    echo "$clipboard_content" | pandoc -f "$input_format" -t html | xclip -selection clipboard -t text/html
    echo "Formatted HTML written to clipboard (MIME type: text/html)."
    exit 0
fi

# Default: plain text transformation
converted=$(echo "$clipboard_content" | pandoc -f "$input_format" -t "$output_format")
echo "$converted" | xclip -selection clipboard
echo "Clipboard transmuted from '$input_format' to '$output_format'."

