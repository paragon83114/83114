#!/usr/bin/env bash
set -euo pipefail

cyan='\033[0;36m'
green='\033[0;32m'
yellow='\033[1;33m'
bold='\033[1m'
reset='\033[0m'

print_header() {
    echo -e "${bold}${cyan}┌${bold}──────────────────────────────────────┐${reset}"
    echo -e "${bold}${cyan}│${reset}      ${bold}KEYS & ALIASES - 83114${reset}         ${bold}${cyan}│${reset}"
    echo -e "${bold}${cyan}└${bold}──────────────────────────────────────┘${reset}"
}

print_cols() {
    local col1="$1" col2="$2" col3="$3"
    printf "${bold}%-22s${reset} ${yellow}%-22s${reset} ${green}%-22s${reset}\n" "$col1" "$col2" "$col3"
}

echo ""
print_header
echo ""

echo -e "${bold}${cyan}ALIAS${reset}"
print_cols "ls → lsd" "l → lsd -l" "ll → lsd -lha"
print_cols "c → clear" "v → nvim" "f → NvimTree"
print_cols "nano → nvim" "oc → opencode -c" "t → tree 2"
print_cols "bye → kill -9 -1" "m → shuffle" "ms → select"
print_cols "lg → lazygit" "h → historial" ""

echo ""
echo -e "${bold}${cyan}FUNCIONES${reset}"
print_cols "google <texto>" "minimax <query>" ""

echo ""
echo -e "${bold}${cyan}DIARIO (d)${reset}"
print_cols "d → ver" "d <texto> → entry" "d eval → IA"
print_cols "d today → analisis" "d del → borrar" ""

echo ""
echo -e "${bold}${cyan}MUSICA${reset}"
print_cols "m → shuffle mpv" "ms → fzf select" "" ""

echo ""
echo -e "${bold}${cyan}SCRIPTS${reset}"
print_cols "gmail-check" "gmail-read" "share-send"
print_cols "share-get" "md2pdf" "md2epub"
print_cols "md2docx" "install_mmx" "install_antigravity"

echo ""
echo -e "${bold}${cyan}FZF (Ctrl+R)${reset}"
print_cols "Ctrl+R → history" "Ctrl+T → files" "Alt+C → dirs"
print_cols "Tab → mark" "Enter → select" "ESC → exit"

echo ""
echo -e "${bold}${cyan}NAvegacion${reset}"
print_cols "cd <dir> (zoxide)" "z <dir> (frecuent)" "" ""

echo ""
echo -e "${cyan}Usa ${bold}h${reset}${cyan} o ${bold}Ctrl+R${reset}${cyan} para historial fzf${reset}"
echo ""