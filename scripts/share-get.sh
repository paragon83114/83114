#!/usr/bin/env bash
set -euo pipefail

[ $# -eq 0 ] && { echo "Uso: share-get <archivo>"; exit 1; }
command -v curl &>/dev/null || { echo "curl requerido"; exit 1; }
ip=$(python3 -c "import socket; s = socket.socket(); s.connect(('1.1.1.1', 80)); print(s.getsockname()[0])" 2>/dev/null)
prefix="${ip%.*}"
found=$(python3 -c "
import socket, threading
found = []
def scan(addr):
    try:
        s = socket.socket(); s.settimeout(1); s.connect((addr, 8080)); found.append(addr)
    except: pass
threads = [threading.Thread(target=scan, args=(f'$prefix.{i}',)) for i in range(1,255)]
for t in threads: t.start()
for t in threads: t.join()
print(' '.join(found))
" 2>/dev/null)
[ -z "$found" ] && { echo "Servidor no encontrado"; exit 1; }
curl -L -# -O "http://${found%% *}:8080/$1"