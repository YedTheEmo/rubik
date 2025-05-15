#!/bin/bash

# rubik_wsl.sh - Clipboard to DOCX via Pandoc, for WSL

show_help() {
    cat <<EOF
Usage: ./rubik_wsl.sh [input_format] [output_format]

Defaults:
  input_format  = markdown
  output_format = docx
EOF
}

if [[ "$1" == "--help" ]]; then
    show_help
    exit 0
fi

input_format="${1:-markdown}"
output_format="${2:-docx}"

clipboard_content=$(xclip -selection clipboard -o 2>/dev/null)

if [[ -z "$clipboard_content" ]]; then
    echo "Error: Clipboard is empty or inaccessible."
    exit 1
fi

if [[ "$output_format" == "docx" ]]; then
    linux_path="/mnt/c/Users/$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r')/Documents/rubik_output.docx"

    mkdir -p "$(dirname "$linux_path")"

    echo "$clipboard_content" | pandoc -f "$input_format" -t docx -o "$linux_path"

    win_path=$(wslpath -w "$linux_path")
    echo "DOCX written to: $win_path"
    powershell.exe start "\"$win_path\""
    exit 0
fi

converted=$(echo "$clipboard_content" | pandoc -f "$input_format" -t "$output_format")
echo "$converted" | xclip -selection clipboard
echo "Clipboard transmuted from '$input_format' to '$output_format'."

