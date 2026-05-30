#!/usr/bin/env bash
set -euo pipefail

bold='\033[1m'
cyan='\033[0;36m'
yellow='\033[1;33m'
green='\033[0;32m'
dim='\033[2m'
reset='\033[0m'

cols() { printf "${bold}%-24s${reset} ${yellow}%-24s${reset} ${green}%-24s${reset}\n" "$1" "$2" "$3"; }
sec() { echo -e "\n${bold}${cyan}━━━ $1 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${reset}"; }
hdr() {
    echo -e "${bold}${cyan}┌─────────────────────────────────────────────┐${reset}"
    echo -e "${bold}${cyan}│${reset}        ${bold}KEYS & ALIASES  •  83114${reset}             ${bold}${cyan}│${reset}"
    echo -e "${bold}${cyan}└─────────────────────────────────────────────┘${reset}"
}

echo ""
hdr

sec "NAVEGACION"
cols "cd <dir>"        "zoxide intelligent"  "h | Ctrl+R historial"

sec "ALIAS BASICOS"
cols "ls / l / ll"     "lsd美化列表"         "t tree 2 niveles"
cols "c"               "clear"              "bye kill -1"

sec "EDITORES"
cols "v"               "nvim"               "f NvimTree toggle"
cols "oc"              "opencode -c"        ""

sec "MUSICA"
cols "m"               "mpv shuffle"        "ms fzf + play"

sec "GIT"
cols "lg"              "lazygit"            ""

sec "DIARIO (d)"
cols "d"               "ver diario"         "d <texto> entrada"
cols "d eval"          "procesar IA"        "d today analizar"
cols "d del"           "borrar entrada"     ""

sec "SCRIPTS UTILITARIOS"
cols "gmail-check"      "correos no leidos"  "gmail-read leer"
cols "share-send"      "enviar archivo"     "share-get recibir"
cols "md2pdf"           "→ PDF"              "md2epub → EPUB"
cols "md2docx"          "→ DOCX"             ""

sec "INSTALADORES"
cols "install_mmx"      "mmx-cli"            "install_antigravity"

sec "FZF atajos"
cols "Ctrl+T"          "buscar archivos"    "Ctrl+R historial"
cols "Alt+C"           "cd directorio"      "Tab marcar"
cols "Enter"           "seleccionar"        "ESC salir"

echo -e "\n${dim}Usa h o Ctrl+R para ver historial con fzf${reset}"
echo ""