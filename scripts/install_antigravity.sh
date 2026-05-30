#!/data/data/com.termux/files/usr/bin/bash

set -euo pipefail

NC='\033[0m'
FG_GREEN='\033[38;2;166;227;161m'
FG_YELLOW='\033[38;2;249;226;175m'
FG_RED='\033[38;2;243;139;168m'
FG_SAPPHIRE='\033[38;2;137;180;250m'
FG_TEXT='\033[38;2;205;214;244m'

log()  { echo -e "${FG_GREEN}[✓]${NC} $1" >&2; }
warn() { echo -e "${FG_YELLOW}[!]${NC} $1" >&2; }
error() { echo -e "${FG_RED}[✗]${NC} $1" >&2; exit 1; }

[ -n "${PREFIX:-}" ] || error "Este script es para Termux."

AGY_DATA_DIR="$HOME/.local/share/core-termux-data/antigravity-cli"
MANIFEST_URL="https://antigravity-cli-auto-updater-974169037036.us-central1.run.app/manifests/linux_arm64.json"

_install_deps() {
    log "Instalando dependencias..."
    pkg install glibc-repo -y >/dev/null 2>&1 || error "glibc-repo"
    pkg install glibc clang python jq curl tar -y >/dev/null 2>&1 || error "dependencias"
    log "Dependencias instaladas."
}

_get_latest_version() {
    curl -fsSL "$MANIFEST_URL" | jq -r .version
}

_get_download_url() {
    curl -fsSL "$MANIFEST_URL" | jq -r .url
}

_download_binary() {
    local version=$(_get_latest_version)
    [ -z "$version" ] && error "No se pudo obtener la version de Antigravity."

    log "Version: ${FG_SAPPHIRE}$version${NC}"
    mkdir -p "$AGY_DATA_DIR"

    local url=$(_get_download_url)
    local tarball="$AGY_DATA_DIR/agy.tar.gz"

    curl -fsSL -o "$tarball" "$url" || error "Descarga fallida."
    tar -xzf "$tarball" -C "$AGY_DATA_DIR" || error "Extraccion fallida."
    rm -f "$tarball"

    local bin="$AGY_DATA_DIR/antigravity"
    [ -f "$bin" ] || bin="$AGY_DATA_DIR/agy"
    [ -f "$bin" ] || error "Binario no encontrado."

    chmod +x "$bin"
    log "Binario descargado."
}

_apply_patches() {
    local bin="$AGY_DATA_DIR/antigravity"
    [ -f "$bin" ] || bin="$AGY_DATA_DIR/agy"
    [ -f "$bin" ] || error "Binario no encontrado para parchear."

    log "Aplicando parches VA39..."

    python3 - "$bin" "${AGY_DATA_DIR}/agy.va39" <<'PYEOF'
import sys, shutil, struct, pathlib
src = pathlib.Path(sys.argv[1])
dst = pathlib.Path(sys.argv[2])
shutil.copyfile(src, dst)
data = bytearray(dst.read_bytes())

def get(off): return struct.unpack_from("<I", data, off)[0]
def put(off, word): struct.pack_into("<I", data, off, word)

for off in range(0, len(data), 4):
    w = get(off)
    if (w & 0x7F800000) == 0x53000000:
        immr, imms = (w >> 16) & 0x3F, (w >> 10) & 0x3F
        if immr == 42 and imms == 44:
            put(off, (w & ~((0x3F << 16) | (0x3F << 10))) | (35 << 16) | (37 << 10))
        elif immr == 22 and imms == 21:
            put(off, (w & ~((0x3F << 16) | (0x3F << 10))) | (29 << 16) | (28 << 10))

for off in range(0, len(data) - 4, 4):
    if get(off) == 0x92D3800A and get(off + 4) == 0xF2E0000A:
        put(off, 0x9280000A); put(off + 4, 0xD35DFD4A)

for off in range(0, len(data), 4):
    if get(off) == 0xF2E00029: put(off, 0xD3596129)

word_rewrites = {
    0xD2C20009: 0xD2C00409, 0xD2C2000A: 0xD2C0040A, 0xF2C20008: 0xF2DFF408,
    0xF2C20009: 0xF2DFF409, 0xD2C10009: 0xD2C00209, 0xD2C1000A: 0xD2C0020A,
    0xF2C38008: 0xF2DFF708, 0xF2C38009: 0xF2DFF709, 0x92560A6C: 0x925D0A6C,
    0x92560A6A: 0x925D0A6A, 0xD2C3000D: 0xD2C0060D, 0xD2C3000C: 0xD2C0060C,
    0xD2C08008: 0xD2C00108,
}

for off in range(0, len(data), 4):
    w = get(off)
    if w in word_rewrites: put(off, word_rewrites[w])

for off in range(0, len(data) - 12, 4):
    if get(off) == 0xAA1F03E5 and get(off + 4) == 0xAA1F03E6 and get(off + 8) == 0xD28036E0 and (get(off + 12) & 0xFC000000) == 0x94000000:
        put(off + 8, 0xD2800600)

dst.write_bytes(data)
PYEOF

    chmod +x "$AGY_DATA_DIR/agy.va39"
    log "Parches aplicados."
}

_compile_bootstrapper() {
    log "Compilando bootstrapper..."

    local helper_src="$HOME/agy_helper.c"
    cat > "$helper_src" <<'CEOF'
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <libgen.h>
#include <limits.h>
#include <stdio.h>

int main(int argc, char** argv) {
    unsetenv("LD_PRELOAD");
    unsetenv("LD_LIBRARY_PATH");
    setenv("GODEBUG", "netdns=cgo", 1);
    setenv("SSL_CERT_FILE", "/data/data/com.termux/files/usr/etc/tls/cert.pem", 1);

    char* loader = "/data/data/com.termux/files/usr/glibc/lib/ld-linux-aarch64.so.1";
    char real_bin[] = "/data/data/com.termux/files/home/.local/share/core-termux-data/antigravity-cli/agy.va39";
    char lib_path[] = "/data/data/com.termux/files/usr/glibc/lib";

    char** new_argv = malloc((argc + 4) * sizeof(char*));
    if (!new_argv) return 1;

    new_argv[0] = loader;
    new_argv[1] = "--library-path";
    new_argv[2] = lib_path;
    new_argv[3] = real_bin;
    for (int i = 1; i < argc; i++) new_argv[i + 3] = argv[i];
    new_argv[argc + 3] = NULL;

    execv(loader, new_argv);
    perror("execv");
    free(new_argv);
    return 1;
}
CEOF

    clang -O2 -o "$PREFIX/bin/agy" "$helper_src" 2>&1 || error "Compilacion fallida."
    rm -f "$helper_src"
    chmod +x "$PREFIX/bin/agy"
    log "Bootstrapper compilado."
}

main() {
    if command -v agy &>/dev/null; then
        log "Antigravity ya instalado. Omitiendo."
        return 0
    fi

    log "Instalando Antigravity CLI..."
    _install_deps
    _download_binary
    _apply_patches
    _compile_bootstrapper
    log "Antigravity instalado. Ejecuta ${FG_SAPPHIRE}agy${NC} para iniciar."
}

main "$@"
