#!/data/data/com.termux/files/usr/bin/bash

set -euo pipefail

NC='\033[0m'
FG_GREEN='\033[38;2;166;227;161m'
FG_YELLOW='\033[38;2;249;226;175m'

log()  { echo -e "${FG_GREEN}[✓]${NC} $1" >&2; }
warn() { echo -e "${FG_YELLOW}[!]${NC} $1" >&2; }

[ -n "${PREFIX:-}" ] || { echo "Este script es para Termux." >&2; exit 1; }

if ! command -v npm &>/dev/null; then
    log "Instalando nodejs..."
    pkg install -y nodejs
fi

if ! command -v mmx &>/dev/null; then
    log "Instalando mmx-cli..."
    npm install -g mmx-cli
else
    log "mmx ya instalado."
fi

log "mmx-cli listo."
