#!/usr/bin/env bash
set -e

FONT_SIZE="${FONT_SIZE:-10}"
H1_SIZE="${H1_SIZE:-16}"
H2_SIZE="${H2_SIZE:-14}"
H3_SIZE="${H3_SIZE:-12}"

[ -z "$1" ] && { echo "Uso: $0 <fichero.md>"; exit 1; }
INPUT="$1"
[ ! -f "$INPUT" ] && { echo "Error: no existe '$INPUT'"; exit 1; }

BASENAME="${INPUT%.md}"
OUTPUT="${BASENAME}.epub"
TMP_CSS="${TMPDIR:-/data/data/com.termux/files/usr/tmp}/md2epub_temp.css"

cat > "$TMP_CSS" <<CSSEOF
body { font-size: ${FONT_SIZE}px; max-width: none; margin: 0; padding: 0; }
h1 { font-size: $((${FONT_SIZE} + 6))px; } h2 { font-size: $((${FONT_SIZE} + 4))px; } h3 { font-size: $((${FONT_SIZE} + 2))px; }
CSSEOF

pandoc "$INPUT" -f markdown -t epub --css="$TMP_CSS" -o "$OUTPUT"
rm -f "$TMP_CSS"
echo "EPUB generado: $OUTPUT"
