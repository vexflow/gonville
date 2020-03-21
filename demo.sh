#!/bin/sh

# Shell script to build the Gonville demo file.
#
# Usage: demo.sh [output base name] [lilypond command-line options]

set -e
base="$1"
shift

lilypond --ps -o "$base" "$@" lilydemo.ly
gs -sDEVICE=pngmono -sPAPERSIZE=a4 -r720 -sOutputFile="$base"-pre.png \
   -dBATCH -dNOPAUSE "$base".ps
convert -resize 1400x- -trim -bordercolor white -border 10 \
   "$base"-pre.png "$base".png

lilypond -dbackend=svg -o "$base"-pre "$@" lilydemo.ly
inkscape -D "$base"-pre.svg --export-margin=2 --export-plain-svg="$base".svg
