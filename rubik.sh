#!/bin/bash

# Convert clipboard content from one format to another using pandoc
# Default: markdown to org

# Get input and output formats from args, or default to md → org
input_format="${1:-markdown}"
output_format="${2:-org}"

# Read from clipboard
clipboard_content=$(xclip -selection clipboard -o)

# Check if clipboard is empty
if [[ -z "$clipboard_content" ]]; then
  echo "❌ Clipboard is empty. Aborting."
  exit 1
fi

# Convert using pandoc
converted=$(echo "$clipboard_content" | pandoc -f "$input_format" -t "$output_format")

# Put result back into clipboard
echo "$converted" | xclip -selection clipboard

echo "Clipboard transmuted from '$input_format' to '$output_format'."


