export FZF_DEFAULT_OPTS='
  --height 60%
  --border
  --reverse
  --exact
  --multi
  --header "Tab=marcar  Enter=seleccionar  ESC=salir"
  --color bg+:#{bg_highlight},bg:#{bg},border:#{border},info:#{fg},pointer:#{accent},marker:#{accent}
  --layout=reverse
  --border=rounded
'

export FZF_CTRL_T_COMMAND='find . -type f ! -path "*/.git/*" ! -path "*/node_modules/*" 2>/dev/null | fzf --height 60% --border --reverse --exact --multi --prompt "Archivos: " --header "Tab=marcar  Enter=abrir  ESC=salir"'
export FZF_CTRL_R_COMMAND='eval "$(atuin search --filter-mode=global)" | fzf --height 60% --border --reverse --exact --prompt "Historial: " --header "Enter=ejecutar  ESC=salir"'
export FZF_ALT_C_COMMAND='find . -type d ! -path "*/.git/*" 2>/dev/null | fzf --height 60% --border --reverse --exact --prompt "Directorios: " --header "Enter=cd  ESC=salir"'