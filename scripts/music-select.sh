#!/usr/bin/env bash

MUSIC_DIR="$HOME/storage/music"

cd "$MUSIC_DIR" && ls | fzf --height=100% --border=rounded --prompt="Musica: " --reverse --no-multi --preview-window=right:40% --preview="killall mpv 2>/dev/null ; pwd && mpv --no-video --osd-level=0 "{}""
