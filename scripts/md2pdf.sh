#!/usr/bin/env bash
set -e

FONT_SIZE="${FONT_SIZE:-10}"
H1_SIZE="${H1_SIZE:-16}"
H2_SIZE="${H2_SIZE:-14}"
H3_SIZE="${H3_SIZE:-12}"
MARGIN_LEFT="${MARGIN_LEFT:-2cm}"
MARGIN_RIGHT="${MARGIN_RIGHT:-2cm}"
MARGIN_TOP="${MARGIN_TOP:-2.5cm}"
MARGIN_BOTTOM="${MARGIN_BOTTOM:-2.5cm}"

[ -z "$1" ] && { echo "Uso: $0 <fichero.md>"; exit 1; }
INPUT="$1"
[ ! -f "$INPUT" ] && { echo "Error: no existe '$INPUT'"; exit 1; }

BASENAME="${INPUT%.md}"
OUTPUT="${BASENAME}.pdf"
TMP_HTML="${TMPDIR:-/data/data/com.termux/files/usr/tmp}/md2pdf_temp.html"

pandoc "$INPUT" -f markdown -t html --standalone -H /dev/stdin <<'CSSEOF' > "$TMP_HTML"
<style>
@page { margin-left: MARGIN_LEFT; margin-right: MARGIN_RIGHT; margin-top: MARGIN_TOP; margin-bottom: MARGIN_BOTTOM; }
html { margin: 0; padding: 0; }
body { margin: 0; padding: 0; max-width: none; font-size: FONT_SIZEpx; }
h1 { font-size: H1_SIZEpx; } h2 { font-size: H2_SIZEpx; } h3 { font-size: H3_SIZEpx; }
</style>
CSSEOF

sed -i "s/MARGIN_LEFT/${MARGIN_LEFT}/g; s/MARGIN_RIGHT/${MARGIN_RIGHT}/g; s/MARGIN_TOP/${MARGIN_TOP}/g; s/MARGIN_BOTTOM/${MARGIN_BOTTOM}/g; s/FONT_SIZE/${FONT_SIZE}/g; s/H1_SIZE/${H1_SIZE}/g; s/H2_SIZE/${H2_SIZE}/g; s/H3_SIZE/${H3_SIZE}/g" "$TMP_HTML"

python3 -c "from weasyprint import HTML; HTML(filename='$TMP_HTML').write_pdf('$OUTPUT')"
rm -f "$TMP_HTML"
echo "PDF generado: $OUTPUT"
