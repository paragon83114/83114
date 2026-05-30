# 83114 - Instalador Unificado de Termux

Sistema de instalación y gestión de dotfiles para Termux usando GNU Stow.

## Estructura

```
83114/
├── install.sh              # Instalador interactivo
├── scripts/                # Scripts de instalacion
│   ├── install_mmx.sh      # Instalar mmx-cli
│   ├── install_antigravity.sh # Instalar Antigravity CLI
│   ├── d.sh               # Diario personal
│   ├── gmail-check.sh      # Verificar correos no leidos
│   ├── music-select.sh     # Seleccionar y reproducir musica
│   ├── music-shuffle.sh    # Reproductor musical aleatorio
│   ├── share-send.sh       # Enviar archivos
│   ├── share-get.sh        # Recibir archivos
│   └── md2pdf.sh / md2epub.sh / md2docx.sh # Conversion de documentos
├── templates/              # Plantillas
│   └── daily.md           # Plantilla del diario
└── dotfiles/              # Configuraciones (stow)
    ├── bashrc/.bashrc
    ├── tmux/.tmux.conf
    ├── termux/.termux/
    │   ├── termux.properties
    │   └── font.ttf         # Fuente personalizada
    ├── atuin/.config/atuin/config.toml
    └── nvim/.config/nvim/
        ├── init.lua          # Bootstrap de lazy.nvim
        └── lua/plugins/
            ├── catppuccin.lua    # Tema Catppuccin Mocha
            ├── filemanager.lua    # NvimTree
            ├── lsp-bash.lua      # LSP para Bash
            └── cmp.lua            # Autocompletado nvim-cmp
```

## Componentes Instalados

### Base
- **bashrc**: Configuración de Bash con alias y funciones
- **tmux**: Gestor de terminal multiplexado
- **atuin**: Historial de comandos mejorado
- **termux.properties**: Configuración de Termux
- **font.ttf**: Fuente personalizada para Termux

### Herramientas
- **Neovim**: Editor de texto con plugins
  - lazy.nvim: Gestor de plugins
  - catppuccin: Tema Catppuccin Mocha
  - nvim-tree: Explorador de archivos (`f` o `<leader>e`)
  - nvim-cmp + nvim-lspconfig: Autocompletado y LSP
  - bash-language-server: Soporte LSP para Bash
- **OpenCode**: CLI de Inteligencia Artificial
- **fzf**: Buscador fuzzy
- **zoxide**: Navegación inteligente entre directorios
- **mpv**: Reproductor multimedia
- **yt-dlp**: Descargador de video/audio
- **lazygit**: Interface git para terminal

### Scripts
| Script | Descripcion |
|--------|-------------|
| `d` | Ver diario personal con glow |
| `d "texto"` | Anadir entrada al diario |
| `d eval` | Procesar diario con IA |
| `d del` | Borrar ultima entrada |
| `gmail-check` | Correos no leidos en Gmail |
| `music-select` | Seleccionar y reproducir musica |
| `music-shuffle` | Reproductor musical aleatorio |
| `share-send` | Enviar archivos por red |
| `share-get` | Recibir archivos por red |
| `md2pdf/md2epub/md2docx` | Convertir Markdown a PDF/EPUB/DOCX |
| `install_mmx` | Instalar mmx-cli |
| `install_antigravity` | Instalar Antigravity CLI |

### Alias
| Alias | Comando |
|-------|---------|
| `ls` | lsd |
| `l` | lsd -l |
| `ll` | lsd -lha |
| `c` | clear |
| `nano` | nvim |
| `v` | nvim |
| `f` | nvim -c "NvimTreeToggle" |
| `g` | glow -w220 -p |
| `oc` | opencode -c |
| `t` | lsd -l --tree --depth 2 |
| `bye` | kill -9 -1 |
| `m` | music-shuffle |
| `ms` | music-select |
| `lg` | lazygit |
| `h` | atuin search -i |

### Funciones
| Funcion | Descripcion |
|---------|-------------|
| `google <texto>` | Buscar en Google |
| `minimax <query>` | Buscar con MiniMax AI |

### Servicios
- **Tmux**: Gestor de terminal multiplexado
- **Debian**: Distribucion Linux dentro de Termux (proot-distro)
- **udocker**: Docker sin root
- **Google API**: Integracion con rclone y Gmail
- **Antigravity CLI**: CLI de Indigo DC (instalacion independiente)

### Extras
- **md2pdf**: Convertir Markdown a PDF
- **md2epub**: Convertir Markdown a EPUB
- **md2docx**: Convertir Markdown a DOCX

## Instalacion

### Instalador Unificado

```bash
git clone https://github.com/paragon83114/83114.git
cd 83114
bash install.sh
```

### Instalacion Manual

```bash
# Instalar stow
pkg install stow -y

# Clonar dotfiles
git clone https://github.com/paragon83114/83114.git
cd 83114

# Desplegar dotfiles con stow
stow --target="$HOME" */

# Crear symlinks de scripts en $PREFIX/bin
for f in scripts/*.sh; do
    ln -sf "$(pwd)/$f" "$PREFIX/bin/$(basename "$f" .sh)"
done
```

## Uso

### Menu del Instalador

```bash
bash install.sh
```

```
  INSTALADOR DE TERMUX

  BASE
  [1] Base (Termux + bashrc)
  [2] Scripts (d, gmail-check, music-select, share-send, share-get, music-shuffle, md2pdf, md2epub, md2docx)

  HERRAMIENTAS
  [3] OpenCode (IA CLI)
  [4] Neovim (editor)
  [5] Extras (fzf, zoxide, mpv, yt-dlp)

  SERVICIOS
  [6] Tmux (terminal manager)
  [7] Debian (proot-distro)
  [8] udocker (Docker sin root)
  [9] Google API (rclone + Gmail)

  TODO
  [T] Instalacion completa
```

### Instalar Todo

```bash
bash install.sh
# Seleccionar T
```

### Instalar por Componente

```bash
# Solo dotfiles
stow --target="$HOME" */

# Solo scripts (symlinks a PREFIX/bin)
for f in scripts/*.sh; do
    ln -sf "$(pwd)/$f" "$PREFIX/bin/$(basename "$f" .sh)"
done
```

## Gestion de Dotfiles con Stow

### Agregar nuevo dotfile

```bash
# Crear estructura: dotfiles/<paquete>/<ruta>/<archivo>
# Ejemplo: agregar ~/.config/fzf/config
mkdir -p dotfiles/fzf/.config/fzf
cp ~/.config/fzf/config dotfiles/fzf/.config/fzf/

# Desplegar
stow --target="$HOME" */
```

### Remover dotfiles

```bash
# Desplegar de nuevo (sobrescribe)
stow --target="$HOME" -D <paquete>
```

## Scripts Utilitarios

### share-send / share-get

Transferir archivos entre dispositivos en la misma red.

```bash
# Dispositivo emisor
share-send archivo.txt

# Dispositivo receptor
share-get
```

### music-shuffle

```bash
music-shuffle
```

### d

Diario personal. Sin args: ver con glow. Con args: anadir entrada.

```bash
d                  # Ver diario
d "texto"          # Anadir entrada
d eval             # Procesar con IA
d del              # Borrar ultima entrada
```

## Neovim

### Atajos de Teclado

| Atajo | Accion |
|-------|--------|
| `<leader>e` | Toggle NvimTree |
| `f` | Toggle NvimTree (alias) |
| `I` | Toggle archivos ocultos en NvimTree |
| `<CR>` | Abrir archivo en NvimTree |

### Instalar plugins

```bash
nvim --headless "+Lazy! sync" +qa
```

## Configuracion Post-Instalacion

### Termux Setup

```bash
# Configurar almacenamiento
termux-setup-storage

# Recargar configuracion
termux-reload-settings
```

## Requisitos

- Termux (Android)
- Git
- Stow
- Bash 4+

## Licencia

MIT
