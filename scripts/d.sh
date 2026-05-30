#!/usr/bin/env bash
set -euo pipefail

diario="$HOME/daily.md"
yellow="\033[1;33m"
red="\033[1;31m"
green="\033[1;32m"
reset="\033[0m"

cd ~

if [ ! -f "$diario" ]; then
  cp ~/83114/templates/daily.md "$diario" 2>/dev/null || touch "$diario"
fi

if [ $# -eq 0 ]; then
  [ -s "$diario" ] && nvim "$diario" || echo -e "${yellow}Diario vacio. Usa: d \"texto\"${reset}"
  exit 0
fi

if [ "$1" = "eval" ]; then
  last_entry=0
  last_eval=0
  [ -f "$HOME/.diario_last_entry" ] && last_entry=$(<"$HOME/.diario_last_entry")
  [ -f "$HOME/.diario_last_eval" ] && last_eval=$(<"$HOME/.diario_last_eval")

  if [ "$last_entry" -gt "$last_eval" ] || [ ! -f "$HOME/.diario_last_eval" ] || [ "${2:-}" = "--force" ]; then
    echo -e "${yellow}Evaluando diario...${reset}"
    mkdir -p "$HOME/daily_backups"
    cp "$diario" "$HOME/daily_backups/daily.md.$(date +%d%m%y_%H%M%S)" 2>/dev/null
    opencode run -m opencode/deepseek-v4-flash-free "procesa el fichero $diario" && date +%s >"$HOME/.diario_last_eval" && echo -e "${green}OK${reset}" || {
      echo -e "${red}Error${reset}"
      exit 1
    }
  else
    echo -e "${green}Ya procesado${reset}"
  fi
  exit 0
fi

if [ "$1" = "today" ]; then
  echo -e "${yellow}Analizando diario...${reset}"
  opencode run -m opencode/deepseek-v4-flash-free "del fichero $diario extrae y muestra:
1. Entradas del dia de hoy.
  2. Temas pendientes (TODO).
3. Proxima cita (la mas cercana)
 Formatea con Headers claros y en markdown" && echo -e "${green}OK${reset}" || {
    echo -e "${red}Error${reset}"
    exit 1
  }
  exit 0
fi

if [ "$1" = "del" ]; then
  [ ! -f "$diario" ] && {
    echo -e "${red}No existe${reset}"
    exit 1
  }
  ult=$(grep -n "### " "$diario" | tail -n 1 | cut -d: -f1)
  [ -z "$ult" ] && {
    echo -e "${yellow}Sin entradas${reset}"
    exit 0
  }
  hasta=$((ult - 1))
  [ "$hasta" -le 0 ] && {
    echo -e "${red}Formato inesperado${reset}"
    exit 1
  }
  head -n "$hasta" "$diario" >"$TMPDIR/daily_tmp.md" && mv "$TMPDIR/daily_tmp.md" "$diario"
  echo -e "${red}Eliminado${reset}"
  exit 0
fi

[ ! -s "$diario" ] && echo -e "# Diario Personal\n" >"$diario"
fecha=$(date '+%d de %b de %Y')
hora=$(date '+%H:%M')
grep -q "## ${fecha}" "$diario" || echo -e "\n---\n\n## ${fecha}\n" >>"$diario"
echo -e "### ${hora}\n\n$*\n" >>"$diario"
echo -e "${green}Guardado${reset}"
date +%s >"$HOME/.diario_last_entry"
