#!/data/data/com.termux/files/usr/bin/bash

set -euo pipefail

NC='\033[0m'

BG_DARK='\033[48;2;49;50;68m'
BG_SAPPHIRE='\033[48;2;137;180;250m'
BG_MANTLE='\033[48;2;24;24;37m'
BG_CRUST='\033[48;2;30;30;46m'

FG_SAPPHIRE='\033[38;2;137;180;250m'
FG_MAUVE='\033[38;2;203;166;227m'
FG_GREEN='\033[38;2;166;227;161m'
FG_YELLOW='\033[38;2;249;226;175m'
FG_RED='\033[38;2;243;139;168m'
FG_TEXT='\033[38;2;205;214;244m'
FG_SUBTEXT='\033[38;2;147;153;186m'
FG_OVERLAY='\033[38;2;245;245;245m'
FG_DARK='\033[38;2;17;17;27m'

log()  { echo -e "${FG_GREEN}[✓]${NC} $1" >&2; }
warn() { echo -e "${FG_YELLOW}[!]${NC} $1" >&2; }
error() { echo -e "${FG_RED}[✗]${NC} $1" >&2; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

[ -n "${PREFIX:-}" ] || error "Este script es para Termux nativo."

if command -v curl &>/dev/null; then
    curl -s --connect-timeout 5 http://1.1.1.1 >/dev/null || curl -s --connect-timeout 5 http://8.8.8.8 >/dev/null || error "Sin conexion a Internet."
else
    ping -c 1 -W 5 1.1.1.1 &>/dev/null || ping -c 1 -W 5 8.8.8.8 &>/dev/null || error "Sin conexion a Internet."
fi

instalar_si_falta() {
    local paquete="$1"
    local comando="${2:-$1}"
    if ! command -v "$comando" &>/dev/null; then
        log "Instalando $paquete..."
        pkg install -y "$paquete"
    else
        log "$paquete ya instalado. Omitiendo."
    fi
}

instalar_stow() {
    if ! command -v stow &>/dev/null; then
        log "Instalando stow..."
        pkg install stow -y
    fi
}

dotfiles_stow() {
    log "Aplicando dotfiles con stow..."

    for f in ~/.bashrc ~/.tmux.conf; do
        [ -f "$f" ] || [ -L "$f" ] && rm -f "$f"
    done

    if [ -L "$HOME/.config" ]; then
        rm -f "$HOME/.config"
    fi

    for d in ~/.config/nvim ~/.termux; do
        if [ -L "$d" ]; then
            rm -f "$d"
        elif [ -d "$d" ]; then
            rm -rf "$d"
        fi
    done

    rm -f ~/bashrc ~/tmux.conf ~/.bashrc.bak.* ~/.tmux.conf.bak.* 2>/dev/null || true

    cd "$SCRIPT_DIR/dotfiles"
    stow --target="$HOME" */
    cd "$SCRIPT_DIR"
    log "Dotfiles aplicados."
}

instalar_base() {
    log "Instalando base de Termux..."

    touch "$HOME/.hushlogin"

    log "Actualizando paquetes..."
    pkg update -y && pkg upgrade -y -o Dpkg::Options::="--force-confnew"

    instalar_si_falta "lsd"

    log "Instalando bash-preexec..."
    mkdir -p "$HOME/.local/share/bash-preexec"
    if [ ! -f "$HOME/.local/share/bash-preexec/bash-preexec.sh" ]; then
        curl -fsSL https://raw.githubusercontent.com/rcaloras/bash-preexec/master/bash-preexec.sh -o "$HOME/.local/share/bash-preexec/bash-preexec.sh"
    fi

    log "Aplicando dotfiles..."
    instalar_stow
    dotfiles_stow

    if [ ! -d "$HOME/storage" ]; then
        log "Configurando almacenamiento..."
        termux-setup-storage
    fi

    log "Base instalada."
}

instalar_funciones() {
    log "Instalando scripts..."

    shopt -s nullglob
    local scripts=("$SCRIPT_DIR/scripts/"*.sh)
    shopt -u nullglob

    if [ ${#scripts[@]} -eq 0 ]; then
        warn "No se encontraron scripts en $SCRIPT_DIR/scripts/"
        return 0
    fi

    for script in "${scripts[@]}"; do
        name=$(basename "$script" .sh)
        ln -sf "$script" "$PREFIX/bin/$name"
    done

    log "Scripts instalados."
}

instalar_opencode() {
    log "Instalando OpenCode..."

    if [ ! -f "$PREFIX/glibc/lib/ld-linux-aarch64.so.1" ]; then
        log "Configurando glibc..."
        pkg install -y glibc-repo
        pkg update -y
        pkg install -y glibc
    fi

    instalar_si_falta "curl"
    instalar_si_falta "git"
    instalar_si_falta "nodejs" "npm"
    instalar_si_falta "ripgrep" "rg"

    log "Limpiando OpenCode anterior..."
    rm -rf "$HOME/.opencode"
    rm -rf "$HOME/.cache/opencode"
    rm -rf "$HOME/.config/opencode"
    rm -rf "$HOME/.local/share/opencode"

    curl -fsSL https://opencode.ai/install | bash -s -- --no-modify-path

    BIN_DIR="$HOME/.opencode/bin"
    [ -f "$BIN_DIR/opencode" ] || [ -f "$BIN_DIR/opencode-bin" ] || error "No se encontro opencode"

    if [ -f "$BIN_DIR/opencode" ] && [ ! -f "$BIN_DIR/opencode-bin" ]; then
        mv "$BIN_DIR/opencode" "$BIN_DIR/opencode-bin"
    fi

    GLIBC_LD="$PREFIX/glibc/lib/ld-linux-aarch64.so.1"
    [ -f "$GLIBC_LD" ] || error "No se encontro linker glibc."

    cat > "$BIN_DIR/opencode" << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
unset LD_PRELOAD LD_LIBRARY_PATH
export JSC_useJIT=false BUN_JIT=0
exec "$PREFIX/glibc/lib/ld-linux-aarch64.so.1" \
    --library-path "$PREFIX/glibc/lib" \
    "$HOME/.opencode/bin/opencode-bin" "$@"
EOF
    chmod +x "$BIN_DIR/opencode"

    mkdir -p "$HOME/.cache/opencode/bin"
    cp "$PREFIX/bin/rg" "$HOME/.cache/opencode/bin/rg" 2>/dev/null || true

    log "OpenCode instalado."
}

instalar_tmux() {
    log "Instalando Tmux..."

    instalar_si_falta "tmux"
    instalar_si_falta "python"

    log "Limpiando Tmux anterior..."
    rm -f "$HOME/.tmux.conf"
    rm -f "$HOME/.tmux.conf.bak" 2>/dev/null || true

    log "Tmux instalado."
}

instalar_vim() {
    log "Instalando Neovim..."

    instalar_si_falta "neovim"
    instalar_si_falta "git"

    if ! command -v npm &>/dev/null; then
        log "Instalando nodejs para bash-language-server..."
        pkg install -y nodejs
    fi

    if ! command -v bash-language-server &>/dev/null; then
        log "Instalando bash-language-server..."
        npm install -g bash-language-server
    fi

    if head -1 "$(command -v bash-language-server)" 2>/dev/null | grep -q '/usr/bin/env'; then
        log "Corrigiendo shebang de bash-language-server..."
        sed -i '1s|#!/usr/bin/env node|#!/data/data/com.termux/files/usr/bin/node|' "$(command -v bash-language-server)"
    fi

    log "Limpiando instalaciones anteriores..."
    rm -rf "$HOME/.config/nvim"
    rm -rf "$HOME/.local/share/nvim"
    rm -rf "$HOME/.local/state/nvim"
    rm -rf "$HOME/.cache/nvim"
    if [ -L "$HOME/.config" ]; then
        rm -f "$HOME/.config"
    fi

    instalar_stow

    log "Aplicando dotfiles de Neovim..."
    cd "$SCRIPT_DIR/dotfiles"
    stow --target="$HOME" nvim
    cd "$SCRIPT_DIR"

    log "Sincronizando plugins..."
    nvim --headless -c "Lazy! sync" +q

    log "Neovim instalado."
}

instalar_extras() {
    log "Instalando extras..."

    log "Limpiando extras anteriores..."
    rm -rf "$HOME/.config/fzf"
    rm -rf "$HOME/.config/glow"
    rm -rf "$HOME/.config/lazygit"
    rm -rf "$HOME/.config/mpv"
    rm -rf "$HOME/.config/rclone"
    rm -rf "$HOME/.local/state/zoxide"
    rm -rf "$HOME/.config/zoxide"
    rm -f "$HOME/.fzf.bash"
    rm -f "$HOME/.fzf.zsh"
    rm -f "$HOME/.termux.bash"

    instalar_si_falta "fzf"
    instalar_si_falta "zoxide"
    instalar_si_falta "mpv"
    instalar_si_falta "yt-dlp"

    log "Extras instalados."
}

instalar_debian() {
    log "Instalando Debian..."

    instalar_si_falta "proot-distro"

    DEBIAN_DIR="$PREFIX/var/lib/proot-distro/installed-rootfs/debian"

    if [ -d "$DEBIAN_DIR" ]; then
        log "Limpiando Debian anterior..."
        proot-distro remove debian --force 2>/dev/null || true
        rm -rf "$PREFIX/var/lib/proot-distro/installed-rootfs/debian" 2>/dev/null || true
    fi

    log "Instalando Debian (esto puede tardar)..."
    proot-distro install debian
    log "Actualizando Debian..."
    proot-distro login debian -- sh -c "apt update && apt upgrade -y"

    log "Debian instalado."
}

instalar_udocker() {
    log "Instalando udocker..."

    log "Limpiando udocker anterior..."
    rm -f "$PREFIX/bin/udocker" 2>/dev/null || true
    rm -f "$PREFIX/bin/udocker.py" 2>/dev/null || true
    rm -rf "$HOME/.udocker" 2>/dev/null || true
    rm -rf "$HOME/.local/share/udocker" 2>/dev/null || true
    rm -rf "$HOME/.cache/udocker" 2>/dev/null || true

    pkg install udocker -y

    log "udocker instalado."
}

instalar_api_google() {
    log "Instalando Google API..."

    instalar_si_falta "rclone"

    if [ ! -f "$HOME/.gmail-creds" ] || [ ! -s "$HOME/.gmail-creds" ]; then
        if [ -t 0 ]; then
            warn "No se detectaron credenciales de Gmail."
            echo -e "${FG_YELLOW}Genera App Password en: https://myaccount.google.com/security${NC}" >&2
            read -r -p "Correo Gmail: " gmail_user
            read -r -s -p "App Password: " gmail_pass
            echo "" >&2
            if [ -n "$gmail_user" ] && [ -n "$gmail_pass" ]; then
                printf '%s\n%s\n' "$gmail_user" "$gmail_pass" > "$HOME/.gmail-creds"
                chmod 600 "$HOME/.gmail-creds"
            fi
        else
            warn "Modo no interactivo. Configura ~/.gmail-creds manualmente."
        fi
    fi

    if ! rclone listremotes 2>/dev/null | grep -q "^drive:"; then
        warn "Configurando rclone..."
        rclone config create drive drive scope drive.readonly 2>&1 || true
    fi

    log "Google API instaladas."
}

instalar_scripts() {
    log "Instalando scripts de conversion..."

    instalar_si_falta "pandoc"
    instalar_si_falta "python"

    if ! command -v pip3 &>/dev/null; then
        warn "pip3 no encontrado. Instalando python-pip..."
        pkg install -y python-pip
    fi

    log "Instalando dependencias de weasyprint..."
    pkg install -y libffi libjpeg-turbo openjpeg zlib

    pip3 install --break-system-packages weasyprint >/dev/null 2>&1 || warn "weasyprint no se pudo instalar."

    log "Scripts instalados."
}

mostrar_menu() {
    clear

    echo -e "${BG_SAPPHIRE}${FG_DARK}  INSTALADOR DE TERMUX  ${NC}\n"

    echo -e "${BG_DARK}  BASE${NC}"
    echo -e "  ${FG_GREEN}[1]${NC}  Base (Termux + bashrc)"
    echo -e "  ${FG_GREEN}[2]${NC}  Scripts (d, gmail-check, music-select, share-send, share-get, music-shuffle, md2pdf, md2epub, md2docx)"
    echo ""

    echo -e "${BG_DARK}  HERRAMIENTAS${NC}"
    echo -e "  ${FG_GREEN}[3]${NC}  OpenCode (IA CLI)"
    echo -e "  ${FG_GREEN}[4]${NC}  Neovim (editor)"
    echo -e "  ${FG_GREEN}[5]${NC}  Extras (fzf, zoxide, mpv, yt-dlp)"
    echo ""

    echo -e "${BG_DARK}  SERVICIOS${NC}"
    echo -e "  ${FG_GREEN}[6]${NC}  Tmux (terminal manager)"
    echo -e "  ${FG_GREEN}[7]${NC}  Debian (proot-distro)"
    echo -e "  ${FG_GREEN}[8]${NC}  udocker (Docker sin root)"
    echo -e "  ${FG_GREEN}[9]${NC}  Google API (rclone + Gmail)"
    echo ""

    echo -e "${BG_MANTLE}  TODO${NC}"
    echo -e "  ${FG_SAPPHIRE}[T]${NC}  Instalacion completa"
    echo ""

    echo -e "  ${FG_RED}[0]${NC}  Salir"
    echo ""
}

procesar_opcion() {
    case "$1" in
        1) echo -e "\n${FG_YELLOW}Instalando base...${NC}"; instalar_base ;;
        2) echo -e "\n${FG_YELLOW}Instalando scripts...${NC}"; instalar_funciones && instalar_scripts ;;
        3) echo -e "\n${FG_YELLOW}Instalando OpenCode...${NC}"; instalar_opencode ;;
        4) echo -e "\n${FG_YELLOW}Instalando Neovim...${NC}"; instalar_vim ;;
        5) echo -e "\n${FG_YELLOW}Instalando extras...${NC}"; instalar_extras ;;
        6) echo -e "\n${FG_YELLOW}Instalando Tmux...${NC}"; instalar_tmux ;;
        7) echo -e "\n${FG_YELLOW}Instalando Debian...${NC}"; instalar_debian ;;
        8) echo -e "\n${FG_YELLOW}Instalando udocker...${NC}"; instalar_udocker ;;
        9) echo -e "\n${FG_YELLOW}Instalando Google API...${NC}"; instalar_api_google ;;
        t|T)
            echo -e "\n${FG_SAPPHIRE}=== INSTALACION COMPLETA ===${NC}"
            instalar_base || warn "Error en instalar_base"
            instalar_funciones || warn "Error en instalar_funciones"
            instalar_scripts || warn "Error en instalar_scripts"
            instalar_opencode || warn "Error en instalar_opencode"
            instalar_vim || warn "Error en instalar_vim"
            instalar_extras || warn "Error en instalar_extras"
            instalar_tmux || warn "Error en instalar_tmux"
            instalar_debian || warn "Error en instalar_debian"
            instalar_udocker || warn "Error en instalar_udocker"
            instalar_api_google || warn "Error en instalar_api_google"
            echo -e "${FG_SAPPHIRE}=== COMPLETADO ===${NC}"
            ;;
        0) echo -e "\n${FG_TEXT}Hasta luego!${NC}\n"; exit 0 ;;
        *) echo -e "\n${FG_RED}Opcion invalida${NC}" ;;
    esac
}

while true; do
    mostrar_menu
    echo -n "Selecciona opcion: "
    read -r opcion
    procesar_opcion "$opcion"
    echo ""
    echo -n "Enter para continuar..."
    read -r
done
