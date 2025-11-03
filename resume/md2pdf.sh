#!/bin/bash

# Convert cv.md to cv.pdf with professional formatting
# This script uses the same pandoc parameters as build_cv.R

echo "Converting cv.md to cv.pdf..."

pandoc cv.md -o cv.pdf \
    -V geometry:margin=0.25in \
    -V linkcolor=brown \
    -V urlcolor=brown \
    -V fontsize=8pt \
    -V linestretch=0.8 \
    -V colorlinks=true \
    -V textcolor=darkgray \
    -V documentclass=article \
    --pdf-engine=xelatex

if [ $? -eq 0 ]; then
    echo "✅ Successfully converted cv.md to cv.pdf"
    ls -la cv.pdf
else
    echo "❌ Error converting cv.md to cv.pdf"
    exit 1
fi