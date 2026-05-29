#!/data/data/com.termux/files/usr/bin/bash

set -e

PREFIX="/data/data/com.termux/files/usr"
HOME_DIR="/data/data/com.termux/files/home"
AGY_DATA_DIR="$HOME_DIR/.local/share/core-termux-data/antigravity-cli"
LOG_FILE="/dev/null"
MANIFEST_URL="https://antigravity-cli-auto-updater-974169037036.us-central1.run.app/manifests/linux_arm64.json"

D_CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

log_info() { echo -e "${D_CYAN}[*]${NC} $*"; }
log_success() { echo -e "${GREEN}[+]${NC} $*"; }
log_error() { echo -e "${RED}[-]${NC} $*" >&2; }

loading() {
    local msg="$1"
    local cmd="$2"
    log_info "$msg..."
    if $cmd; then
        return 0
    else
        return 1
    fi
}

_install_deps() {
    if ! pkg install glibc-repo -y 2>&1 | tail -3; then
        log_error "Failed to install glibc-repo"
        return 1
    fi
    if ! pkg install glibc clang python jq curl tar -y 2>&1 | tail -3; then
        log_error "Failed to install dependencies"
        return 1
    fi
    log_success "Dependencies installed"
    return 0
}

_get_latest_agy_version() {
    curl -fsSL "$MANIFEST_URL" | jq -r .version
}

_get_agy_download_url() {
    curl -fsSL "$MANIFEST_URL" | jq -r .url
}

_download_agy_binary() {
    local latest_version
    latest_version=$(_get_latest_agy_version)
    if [ -z "$latest_version" ]; then
        log_error "Failed to fetch latest Antigravity version"
        return 1
    fi
    log_info "Latest version: ${D_CYAN}$latest_version${NC}"
    mkdir -p "$AGY_DATA_DIR"
    local download_url
    download_url=$(_get_agy_download_url)
    local tarball="$AGY_DATA_DIR/agy.tar.gz"
    if ! curl -fsSL -o "$tarball" "$download_url"; then
        log_error "Failed to download Antigravity CLI binary"
        return 1
    fi
    if ! tar -xzf "$tarball" -C "$AGY_DATA_DIR"; then
        log_error "Failed to extract Antigravity CLI binary"
        return 1
    fi
    rm -f "$tarball"
    local upstream_bin=""
    if [ -f "$AGY_DATA_DIR/antigravity" ]; then
        upstream_bin="$AGY_DATA_DIR/antigravity"
    elif [ -f "$AGY_DATA_DIR/agy" ]; then
        upstream_bin="$AGY_DATA_DIR/agy"
    else
        log_error "Could not find binary in extracted archive"
        return 1
    fi
    chmod +x "$upstream_bin"
    log_success "Antigravity CLI binary downloaded"
    return 0
}

_apply_va39_patches() {
    local upstream_bin=""
    if [ -f "$AGY_DATA_DIR/antigravity" ]; then
        upstream_bin="$AGY_DATA_DIR/antigravity"
    elif [ -f "$AGY_DATA_DIR/agy" ]; then
        upstream_bin="$AGY_DATA_DIR/agy"
    else
        log_error "Binary not found for patching"
        return 1
    fi
    log_info "Applying VA39 memory patches..."
    python3 - "$upstream_bin" "${AGY_DATA_DIR}/agy.va39" <<'PY'
import sys, shutil, struct, pathlib
src = pathlib.Path(sys.argv[1])
dst = pathlib.Path(sys.argv[2])
shutil.copyfile(src, dst)
data = bytearray(dst.read_bytes())
def get(off): return struct.unpack_from("<I", data, off)[0]
def put(off, word): struct.pack_into("<I", data, off, word)
lo, hi = 0, len(data)
for off in range(lo, hi, 4):
    w = get(off)
    if (w & 0x7F800000) == 0x53000000:
        immr, imms = (w >> 16) & 0x3F, (w >> 10) & 0x3F
        if immr == 42 and imms == 44:
            put(off, (w & ~((0x3F << 16) | (0x3F << 10))) | (35 << 16) | (37 << 10))
        elif immr == 22 and imms == 21:
            put(off, (w & ~((0x3F << 16) | (0x3F << 10))) | (29 << 16) | (28 << 10))
for off in range(lo, hi - 4, 4):
    if get(off) == 0x92D3800A and get(off + 4) == 0xF2E0000A:
        put(off, 0x9280000A); put(off + 4, 0xD35DFD4A)
for off in range(lo, hi, 4):
    if get(off) == 0xF2E00029: put(off, 0xD3596129)
word_rewrites = {
    0xD2C20009: 0xD2C00409, 0xD2C2000A: 0xD2C0040A, 0xF2C20008: 0xF2DFF408,
    0xF2C20009: 0xF2DFF409, 0xD2C10009: 0xD2C00209, 0xD2C1000A: 0xD2C0020A,
    0xF2C38008: 0xF2DFF708, 0xF2C38009: 0xF2DFF709, 0x92560A6C: 0x925D0A6C,
    0x92560A6A: 0x925D0A6A, 0xD2C3000D: 0xD2C0060D, 0xD2C3000C: 0xD2C0060C,
    0xD2C08008: 0xD2C00108,
}
for off in range(lo, hi, 4):
    w = get(off)
    if w in word_rewrites: put(off, word_rewrites[w])
for off in range(0, len(data) - 12, 4):
    if get(off) == 0xAA1F03E5 and get(off + 4) == 0xAA1F03E6 and get(off + 8) == 0xD28036E0 and (get(off + 12) & 0xFC000000) == 0x94000000:
        put(off + 8, 0xD2800600)
dst.write_bytes(data)
PY
    chmod +x "$AGY_DATA_DIR/agy.va39"
    log_success "VA39 patches applied"
    return 0
}

_download_and_compile_helper() {
    local helper_src="$HOME_DIR/agy_helper.c"
    cat > "$helper_src" <<'CPYEOF'
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
    if (!new_argv) {
        return 1;
    }

    new_argv[0] = loader;
    new_argv[1] = "--library-path";
    new_argv[2] = lib_path;
    new_argv[3] = real_bin;

    for (int i = 1; i < argc; i++) {
        new_argv[i + 3] = argv[i];
    }
    new_argv[argc + 3] = NULL;

    execv(loader, new_argv);

    perror("execv");
    free(new_argv);
    return 1;
}
CPYEOF
    if ! clang -O2 -o "$PREFIX/bin/agy" "$helper_src" 2>&1; then
        log_error "Failed to compile agy helper"
        rm -f "$helper_src"
        return 1
    fi
    rm -f "$helper_src"
    chmod +x "$PREFIX/bin/agy"
    log_success "Bootstrapper compiled to $PREFIX/bin/agy"
    return 0
}

main() {
    if command -v agy &>/dev/null; then
        log_info "Antigravity CLI already installed"
        exit 0
    fi
    log_info "Installing Antigravity CLI..."
    loading "Installing dependencies" _install_deps || exit 1
    loading "Downloading Antigravity CLI" _download_agy_binary || exit 1
    loading "Applying VA39 patches" _apply_va39_patches || exit 1
    loading "Compiling bootstrapper" _download_and_compile_helper || exit 1
    log_success "Antigravity CLI installed! Run 'agy' to start."
}

main "$@"
