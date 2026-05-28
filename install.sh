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
    curl -s --connect-timeout 5 https://1.1.1.1 >/dev/null || error "Sin conexion a Internet."
else
    ping -c 1 -W 5 1.1.1.1 &>/dev/null || error "Sin conexion a Internet."
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
        if [ -f "$f" ] && [ ! -L "$f" ]; then
            mv "$f" "${f}.bak.$(date +%s)"
        fi
        [ -L "$f" ] && rm "$f"
    done

    for d in ~/.config/atuin ~/.config/nvim ~/.termux; do
        if [ -d "$d" ] && [ ! -L "$d" ]; then
            mv "$d" "${d}.bak.$(date +%s)"
        fi
        [ -L "$d" ] && rm "$d"
    done

    for f in ~/bashrc ~/tmux.conf ~/config.toml ~/init.lua ~/lua ~/termux.properties; do
        [ -e "$f" ] && rm -f "$f"
    done

    cd "$SCRIPT_DIR/dotfiles"
    stow --target="$HOME" */
    cd "$SCRIPT_DIR"
    log "Dotfiles aplicados."
}

instalar_base() {
    log "Instalando base de Termux..."

    if [ ! -d "$HOME/storage" ]; then
        log "Configurando almacenamiento..."
        termux-setup-storage
    fi

    touch "$HOME/.hushlogin"

    log "Actualizando paquetes..."
    pkg update -y && pkg upgrade -y -o Dpkg::Options::="--force-confnew"

    if [ ! -f "$HOME/.termux/font.ttf" ]; then
        log "Descargando JetBrains Mono Nerd Font..."
        mkdir -p "$HOME/.termux"
        curl -L "https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/JetBrainsMono/Ligatures/Regular/JetBrainsMonoNerdFont-Regular.ttf" -o "$HOME/.termux/font.ttf"
        termux-reload-settings
    fi

    instalar_si_falta "lsd"
    instalar_si_falta "glow"
    instalar_si_falta "atuin"

    log "Instalando bash-preexec..."
    mkdir -p "$HOME/.local/share/bash-preexec"
    if [ ! -f "$HOME/.local/share/bash-preexec/bash-preexec.sh" ]; then
        curl -fsSL https://raw.githubusercontent.com/rcaloras/bash-preexec/master/bash-preexec.sh -o "$HOME/.local/share/bash-preexec/bash-preexec.sh"
    fi

    log "Aplicando dotfiles..."
    instalar_stow
    dotfiles_stow

    log "Base instalada."
}

instalar_funciones() {
    log "Instalando scripts..."

    cp -r "$SCRIPT_DIR/scripts" "$HOME/"
    chmod +x "$HOME/scripts/"*.sh

    log "Creando enlaces en $PREFIX/bin..."
    for script in "$HOME/scripts/"*.sh; do
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

    if [ -f "$HOME/.opencode/bin/opencode" ] || [ -f "$HOME/.opencode/bin/opencode-bin" ]; then
        log "OpenCode ya instalado. Omitiendo."
    else
        rm -rf "$HOME/.opencode"
        curl -fsSL https://opencode.ai/install | bash -s -- --no-modify-path
    fi

    BIN_DIR="$HOME/.opencode/bin"
    [ -f "$BIN_DIR/opencode" ] || [ -f "$BIN_DIR/opencode-bin" ] || error "No se encontro opencode"

    if [ -f "$BIN_DIR/opencode" ] && [ ! -f "$BIN_DIR/opencode-bin" ]; then
        mv "$BIN_DIR/opencode" "$BIN_DIR/opencode-bin"
    fi

    GLIBC_LD="$PREFIX/glibc/lib/ld-linux-aarch64.so.1"
    [ -f "$GLIBC_LD" ] || error "No se encontro linker glibc."

    if ! grep -q "unset LD_PRELOAD" "$BIN_DIR/opencode" 2>/dev/null; then
        cat > "$BIN_DIR/opencode" << EOF
#!/data/data/com.termux/files/usr/bin/bash
unset LD_PRELOAD LD_LIBRARY_PATH
export JSC_useJIT=false BUN_JIT=0
exec "$PREFIX/glibc/lib/ld-linux-aarch64.so.1" \
    --library-path "$PREFIX/glibc/lib" \
    "$HOME/.opencode/bin/opencode-bin" "\$@"
EOF
        chmod +x "$BIN_DIR/opencode"
    fi

    mkdir -p "$HOME/.cache/opencode/bin"
    [ ! -f "$HOME/.cache/opencode/bin/rg" ] && cp "$PREFIX/bin/rg" "$HOME/.cache/opencode/bin/rg"

    log "OpenCode instalado."
}

instalar_tmux() {
    log "Instalando Tmux..."

    instalar_si_falta "tmux"
    instalar_si_falta "python"

    dotfiles_stow

    cat > "$PREFIX/bin/gmail-check" << 'SCRIPT'
#!/data/data/com.termux/files/usr/bin/bash
python3 -c "
import imaplib
with open('$HOME/.gmail-creds') as f:
    user, pwd = f.read().strip().splitlines()
c = imaplib.IMAP4_SSL('imap.gmail.com')
c.login(user, pwd)
c.select('INBOX')
print(len(c.search(None, 'UNSEEN')[1][0].split()))
c.logout()
" 2>/dev/null || echo "0"
SCRIPT
    chmod +x "$PREFIX/bin/gmail-check"

    log "Tmux instalado."
}

instalar_vim() {
    log "Instalando Neovim..."

    instalar_si_falta "neovim"
    instalar_si_falta "git"

    dotfiles_stow

    nvim --headless "+Lazy! sync" +qa 2>/dev/null || true

    log "Neovim instalado."
}

instalar_extras() {
    log "Instalando extras..."

    instalar_si_falta "fzf"
    instalar_si_falta "zoxide"
    instalar_si_falta "mpv"
    instalar_si_falta "yt-dlp"

    log "Extras instalados."
}

instalar_mmx() {
    log "Instalando mmx-cli..."

    if ! command -v mmx &>/dev/null; then
        npm install -g mmx-cli
    else
        log "mmx ya instalado. Omitiendo."
    fi

    log "mmx-cli instalado."
}

instalar_debian() {
    log "Instalando Debian..."

    instalar_si_falta "proot-distro"

    DEBIAN_DIR="$PREFIX/var/lib/proot-distro/installed-rootfs/debian"

    if [ ! -d "$DEBIAN_DIR" ]; then
        log "Instalando Debian (esto puede tardar)..."
        proot-distro install debian
        log "Actualizando Debian..."
        proot-distro login debian -- sh -c "apt update && apt upgrade -y"
    else
        log "Debian ya instalado."
    fi

    log "Debian instalado."
}

instalar_api_google() {
    log "Instalando Google API..."

    instalar_si_falta "rclone"

    if [ ! -f "$HOME/.gmail-creds" ] || [ ! -s "$HOME/.gmail-creds" ]; then
        warn "No se detectaron credenciales de Gmail."
        echo -e "${FG_YELLOW}Genera App Password en: https://myaccount.google.com/security${NC}" >&2
        read -r -p "Correo Gmail: " gmail_user
        read -r -s -p "App Password: " gmail_pass
        echo "" >&2
        if [ -n "$gmail_user" ] && [ -n "$gmail_pass" ]; then
            printf '%s\n%s\n' "$gmail_user" "$gmail_pass" > "$HOME/.gmail-creds"
            chmod 600 "$HOME/.gmail-creds"
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
    pkg install -y python
    pip install weasyprint 2>/dev/null || pip install weasyprint

    mkdir -p "$HOME/scripts"

    for script in md2pdf md2epub md2docx; do
        cat > "$HOME/scripts/${script}.sh" << 'SCRIPT'
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
SCRIPT

        if [ "$script" = "md2pdf" ]; then
            cat >> "$HOME/scripts/${script}.sh" << 'EOF'
OUTPUT="${BASENAME}.pdf"
TMP_HTML="/data/data/com.termux/files/usr/tmp/md2pdf_temp.html"

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
EOF
        elif [ "$script" = "md2epub" ]; then
            cat >> "$HOME/scripts/${script}.sh" << 'EOF'
OUTPUT="${BASENAME}.epub"
TMP_CSS="/data/data/com.termux/files/usr/tmp/md2epub_temp.css"

cat > "$TMP_CSS" <<CSSEOF
body { font-size: ${FONT_SIZE}px; max-width: none; margin: 0; padding: 0; }
h1 { font-size: $((${FONT_SIZE} + 6))px; } h2 { font-size: $((${FONT_SIZE} + 4))px; } h3 { font-size: $((${FONT_SIZE} + 2))px; }
CSSEOF

pandoc "$INPUT" -f markdown -t epub --css="$TMP_CSS" -o "$OUTPUT"
rm -f "$TMP_CSS"
echo "EPUB generado: $OUTPUT"
EOF
        else
            cat >> "$HOME/scripts/${script}.sh" << 'EOF'
OUTPUT="${BASENAME}.docx"

pandoc "$INPUT" -f markdown -t docx -o "$OUTPUT"
echo "DOCX generado: $OUTPUT"
EOF
        fi
    done

    chmod +x "$HOME/scripts/"*.sh

    log "Creando enlaces en $PREFIX/bin..."
    for script in "$HOME/scripts/"*.sh; do
        name=$(basename "$script" .sh)
        ln -sf "$script" "$PREFIX/bin/$name"
    done

    log "Scripts instalados."
}

mostrar_menu() {
    clear

    echo -e "${BG_SAPPHIRE}${FG_DARK}  INSTALADOR DE TERMUX  ${NC}\n"

    echo -e "${BG_DARK}  BASE${NC}"
    echo -e "  ${FG_GREEN}[1]${NC}  Base (Termux + bashrc)"
    echo -e "  ${FG_GREEN}[2]${NC}  Scripts (d, music-all, share-send, share-get, music-shuffle, md2pdf, md2epub, md2docx)"
    echo ""

    echo -e "${BG_DARK}  HERRAMIENTAS${NC}"
    echo -e "  ${FG_GREEN}[3]${NC}  OpenCode (IA CLI)"
    echo -e "  ${FG_GREEN}[4]${NC}  Neovim (editor)"
    echo -e "  ${FG_GREEN}[5]${NC}  Extras (fzf, zoxide, mpv, yt-dlp)"
    echo -e "  ${FG_GREEN}[6]${NC}  mmx-cli (MiniMax AI)"
    echo ""

    echo -e "${BG_DARK}  SERVICIOS${NC}"
    echo -e "  ${FG_GREEN}[7]${NC}  Tmux (terminal manager)"
    echo -e "  ${FG_GREEN}[8]${NC}  Debian (proot-distro)"
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
        6) echo -e "\n${FG_YELLOW}Instalando mmx-cli...${NC}"; instalar_mmx ;;
        7) echo -e "\n${FG_YELLOW}Instalando Tmux...${NC}"; instalar_tmux ;;
        8) echo -e "\n${FG_YELLOW}Instalando Debian...${NC}"; instalar_debian ;;
        9) echo -e "\n${FG_YELLOW}Instalando Google API...${NC}"; instalar_api_google ;;
        t|T)
            echo -e "\n${FG_SAPPHIRE}=== INSTALACION COMPLETA ===${NC}"
            instalar_base && instalar_funciones && instalar_scripts && instalar_opencode
            instalar_vim && instalar_extras && instalar_mmx
            instalar_tmux && instalar_debian && instalar_api_google
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