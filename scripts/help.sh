#!/usr/bin/env bash
set -euo pipefail

cyan='\033[0;36m'
green='\033[0;32m'
yellow='\033[1;33m'
red='\033[0;31m'
bold='\033[1m'
reset='\033[0m'

print_header() {
    echo -e "${bold}${cyan}╔════════════════════════════════════════════════════════════════╗${reset}"
    echo -e "${bold}${cyan}║${reset}              ${bold}${yellow}COMBINACIONES Y ALIAS - 83114${reset}                   ${bold}${cyan}║${reset}"
    echo -e "${bold}${cyan}╚════════════════════════════════════════════════════════════════╝${reset}"
    echo ""
}

print_section() {
    echo -e "\n${bold}${green}━━━ $1 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${reset}"
}

print_key() {
    printf "  ${bold}${yellow}%-20s${reset}  %s\n" "$1" "$2"
}

print_alias() {
    printf "  ${bold}${cyan}%-20s${reset}  %s\n" "$1" "$2"
}

echo ""
print_header

print_section "ALIAS PRINCIPALES"
print_alias "ls"          "lsd (mejorado)"
print_alias "l"           "lsd -l"
print_alias "ll"          "lsd -lha"
print_alias "c"           "clear"
print_alias "v"           "nvim"
print_alias "f"           "nvim -c 'NvimTreeToggle'"
print_alias "nano"        "nvim"
print_alias "oc"          "opencode -c"
print_alias "t"           "lsd -l --tree --depth 2"
print_alias "bye"         "kill -9 -1"
print_alias "m"           "music-shuffle"
print_alias "ms"          "music-select"
print_alias "lg"          "lazygit"
print_alias "h"           "historial (fzf)"

print_section "FUNCIONES"
print_key "google <texto>"    "Buscar en Google"
print_key "minimax <query>"  "Buscar con MiniMax AI"

print_section "SCRIPTS (d)"
print_key "d"              "Ver diario con nvim"
print_key "d <texto>"      "Añadir entrada al diario"
print_key "d eval"         "Procesar diario con IA"
print_key "d today"        "Analizar diario del dia"
print_key "d del"          "Borrar ultima entrada"

print_section "MUSICA"
print_key "m"              "Reproduccion aleatoria (mpv --shuffle)"
print_key "ms"             "Seleccionar y reproducir con fzf"

print_section "OTROS SCRIPTS"
print_key "gmail-check"    "Verificar correos no leidos"
print_key "gmail-read"     "Leer correos no leidos"
print_key "share-send <f>" "Enviar archivo por red"
print_key "share-get"      "Recibir archivo por red"
print_key "md2pdf <file>"  "Convertir a PDF (pandoc)"
print_key "md2epub <file>" "Convertir a EPUB (pandoc)"
print_key "md2docx <file>" "Convertir a DOCX (pandoc)"
print_key "lg"             "Interfaz git (lazygit)"
print_key "install_mmx"    "Instalar mmx-cli"
print_key "install_antigravity" "Instalar Antigravity CLI"

print_section "FZF - ATAJOS DE TECLADO"
print_key "Ctrl+R"         "Historial de comandos"
print_key "Ctrl+T"         "Buscar archivos"
print_key "Alt+C"          "Cambiar a directorio"
print_key "Tab"            "Marcar (multi-select)"
print_key "Enter"          "Seleccionar/Ejecutar"
print_key "ESC"            "Salir"

print_section "DIARIO (d)"
print_key "d"              "Ver diario"
print_key "d \"texto\""    "Nueva entrada"
print_key "d eval"         "Procesar con IA"
print_key "d today"        "Resumen del dia"
print_key "d del"          "Eliminar entrada"

echo ""
echo -e "${bold}${cyan}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${reset}"
echo -e "${yellow}Usa ${bold}Ctrl+R${reset}${yellow} para buscar en el historial o ${bold}h${reset}${yellow} para ver interfaz fzf${reset}"
echo ""