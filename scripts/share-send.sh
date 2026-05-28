#!/usr/bin/env bash
set -euo pipefail

port=${1:-8080}
command -v python3 &>/dev/null || { echo "Python requerido"; exit 1; }
python3 -c "import socket; s = socket.socket(); s.bind(('', $port))" 2>/dev/null || { echo "Puerto $port en uso"; exit 1; }
ip=$(python3 -c "import socket; s = socket.socket(); s.connect(('1.1.1.1', 80)); print(s.getsockname()[0])" 2>/dev/null)
echo "Compartir: http://${ip:-?}:${port}"
python3 -m http.server "$port"