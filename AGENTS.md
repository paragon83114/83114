# 83114 - Termux Dotfiles

Termux-only dotfiles managed with GNU Stow.

## Quick Start

```bash
bash install.sh           # Interactive menu
# Select T for full install
```

## Dotfile Management

```bash
stow --target="$HOME" */   # Deploy all packages
stow --target="$HOME" -D <package>  # Remove a package
```

packages: `bashrc`, `tmux`, `termux`, `nvim`

## Adding New Dotfiles

```bash
# Create: dotfiles/<package>/<path>/<file>
mkdir -p dotfiles/fzf/.config/fzf
cp ~/.config/fzf/config dotfiles/fzf/.config/fzf/
stow --target="$HOME" */
```

## Script Installation

Scripts are symlinked from `scripts/*.sh` to `$PREFIX/bin/` (without `.sh` extension). No files are copied to `$HOME/scripts/`.

```bash
# Manual script installation
for f in scripts/*.sh; do
    ln -sf "$(pwd)/$f" "$PREFIX/bin/$(basename "$f" .sh)"
done
```

## Key Scripts

- `scripts/d.sh` - Personal diary (see below)
- `scripts/gmail-check.sh` - Gmail unread count
- `scripts/share-send.sh` / `scripts/share-get.sh` - LAN file transfer
- `scripts/music-select.sh` / `scripts/music-shuffle.sh` - Music players
- `scripts/md2pdf.sh`, `scripts/md2epub.sh`, `scripts/md2docx.sh` - Document conversion via pandoc

### `d` (diary)
```bash
d              # View with nvim
d "text"       # Add entry
d eval         # Process with AI (opencode/deepseek-v4-flash-free)
d del          # Delete last entry
```

## OpenCode on Termux

`install.sh` sets up a wrapper script that uses glibc's `ld-linux-aarch64.so.1` and unsets `LD_PRELOAD`. If opencode fails to start, check that the wrapper exists at `$HOME/.opencode/bin/opencode` and that the glibc linker is present at `$PREFIX/glibc/lib/ld-linux-aarch64.so.1`.

## Stow Precautions

Before stowing, `install.sh` removes existing files and symlinks at target locations. Symlinks are used, not copies.

## Requirements

- Termux (Android)
- `stow`, `git`, `bash 4+`