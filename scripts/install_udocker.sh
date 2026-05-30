#!/data/data/com.termux/files/usr/bin/bash

set -euo pipefail

NC='\033[0m'
FG_GREEN='\033[38;2;166;227;161m'
FG_YELLOW='\033[38;2;249;226;175m'
FG_SAPPHIRE='\033[38;2;137;180;250m'

log()  { echo -e "${FG_GREEN}[✓]${NC} $1" >&2; }
warn() { echo -e "${FG_YELLOW}[!]${NC} $1" >&2; }
error() { echo -e "${FG_RED}[✗]${NC} $1" >&2; exit 1; }

[ -n "${PREFIX:-}" ] || error "Este script es para Termux."

_install_deps() {
    log "Instalando dependencias..."
    pkg install -y python pip >/dev/null 2>&1 || error "python/pip"
    log "Dependencias instaladas."
}

_download_udocker() {
    log "Descargando udocker..."
    curl -fsSL https://raw.githubusercontent.com/indigo-dc/udocker/master/udocker.py -o "$PREFIX/bin/udocker" || error "Descarga fallida."
    chmod +x "$PREFIX/bin/udocker"
    log "udocker descargado."
}

_setup_udocker() {
    log "Configurando udocker..."
    udocker --version >/dev/null 2>&1 || error "udocker no funciona."
    log "udocker configurado."
}

main() {
    if command -v udocker &>/dev/null; then
        log "udocker ya instalado. Omitiendo."
        return 0
    fi

    log "Instalando udocker..."
    _install_deps
    _download_udocker
    _setup_udocker
    log "udocker instalado. Ejecuta ${FG_SAPPHIRE}udocker help${NC} para ver comandos."
}

main "$@"
