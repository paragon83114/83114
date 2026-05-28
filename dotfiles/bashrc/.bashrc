export LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 EDITOR=nvim
export PATH="$HOME/.opencode/bin:$HOME/bin:$PATH"
export HISTTIMEFORMAT="%F %T "

alias ls="lsd" l="lsd -l" ll="lsd -lha" c="clear" nano="nvim" g="glow -w220 -p" oc="opencode -c" v="nvim" f='nvim -c "lua Snacks.picker.explorer({layout={preset=\"sidebar\"}})"' t="lsd -l --tree --depth 2" bye="kill -9 -1" m="music-shuffle" ms="music-select" lg="cd ~/termux && lazygit"

google() {
    [ $# -eq 0 ] && { echo "Uso: google <termino1> [termino2] ..."; return 1; }
    local query
    query=$(printf '%s' "$*" | sed 's/ /+/g')
    termux-open-url "https://www.google.com/search?q=${query}"
}

minimax() {
    [ $# -eq 0 ] && { echo "Uso: minimax <query>"; return 1; }
    mmx search query --q "$*"
}

__pretty_dir() { echo -n "${PWD/#$HOME/\~}"; }

export HOSTNAME="MiTermux"
R='\[\033[0m\]'
B_SAPPHIRE='\[\033[48;2;137;180;250m\]'
B_DARK='\[\033[48;2;49;50;68m\]'
B_MANTLE='\[\033[48;2;24;24;37m\]'
F_DARK='\[\033[38;2;17;17;27m\]'
F_WHITE='\[\033[38;2;205;214;244m\]'
F_LAVENDER='\[\033[38;2;180;190;254m\]'
F_SAPPHIRE='\[\033[38;2;137;180;250m\]'
S_DARK_TO_SAP='\[\033[38;2;49;50;68;48;2;137;180;250m\]'
S_TO_DARK='\[\033[38;2;137;180;250;48;2;49;50;68m\]'
S_TO_MANTLE='\[\033[38;2;49;50;68;48;2;24;24;37m\]'
S_END='\[\033[38;2;24;24;37m\]'
PS1="${B_DARK}${F_SAPPHIRE} \u ${S_DARK_TO_SAP}${B_SAPPHIRE}${F_DARK} \$HOSTNAME ${S_TO_DARK}${B_DARK}${F_WHITE} \$(__pretty_dir) ${S_TO_MANTLE}${B_MANTLE}${F_LAVENDER} \A ${F_SAPPHIRE}❯ ${R}${S_END}${R} "

command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init bash --cmd cd)"
command -v fzf >/dev/null 2>&1 && eval "$(fzf --bash)"
[ -f "$HOME/.local/share/bash-preexec/bash-preexec.sh" ] && source "$HOME/.local/share/bash-preexec/bash-preexec.sh"
command -v atuin >/dev/null 2>&1 && eval "$(atuin init bash)"

if [ -z "${TMUX:-}" ] && ! pgrep -x tmux >/dev/null; then
    tmux new-session -A -s main
fi
