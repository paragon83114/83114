#!/usr/bin/env bash
set -e

[ -z "$1" ] && { echo "Uso: $0 <fichero.md>"; exit 1; }
INPUT="$1"
[ ! -f "$INPUT" ] && { echo "Error: no existe '$INPUT'"; exit 1; }

BASENAME="${INPUT%.md}"
OUTPUT="${BASENAME}.docx"

pandoc "$INPUT" -f markdown -t docx -o "$OUTPUT"
echo "DOCX generado: $OUTPUT"
