#!/bin/sh

# Copy files to another folder that can be published to workshop

INPUT="$1"
OUTPUT="$2"

# Make output directory
mkdir -p "$OUTPUT"

# Copy all files to output
cp -r "$INPUT/" "$OUTPUT/"

# Remove non-lua files from output
find "$OUTPUT" -type f ! -name '*.lua' -delete

# Copy addon.json
cp "$INPUT/addon.json" "$OUTPUT"

echo "All done!"