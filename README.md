# 83114 - Instalador Unificado de Termux

Sistema de instalación y gestión de dotfiles para Termux usando GNU Stow.

## Estructura

```
83114/
├── install.sh          # Instalador interactivo
├── scripts/            # Scripts utilitarios
│   ├── d.sh           # Navegación rápida
│   ├── music-all.sh     # Reproducir toda la musica
│   ├── music-shuffle.sh # Reproductor musical aleatorio
│   ├── share-send.sh  # Enviar archivos
│   └── share-get.sh   # Recibir archivos
└── dotfiles/          # Configuraciones (stow)
    ├── bashrc/.bashrc
    ├── tmux/.tmux.conf
    ├── termux/.termux/.termux.properties
    ├── atuin/.config/atuin/config.toml
    └── nvim/.config/nvim/
        ├── init.lua
        └── lua/plugins/
            ├── theme.lua
            └── filemanager.lua
```

## Componentes Instalados

### Base
- **bashrc**: Configuración de Bash con alias y funciones
- **tmux**: Gestor de terminal multiplexado
- **termux.properties**: Configuración de Termux

### Herramientas
- **Neovim**: Editor de texto con plugins
  - theme.lua: Tema Catppuccin Mocha
  - filemanager.lua: Integración con file explorer
- **atuin**: Historial de comandos mejorado
- **OpenCode**: CLI de Inteligencia Artificial
- **mmx-cli**: Herramienta MiniMax AI
- **fzf**: Buscador fuzzy
- **zoxide**: Navegación inteligente entre directorios
- **mpv**: Reproductor multimedia
- **yt-dlp**: Descargador de video/audio

### Scripts
| Script | Descripción |
|--------|-------------|
| `d` | Navegación rápida a directorios |
| `music-all` | Reproducir toda la musica |
| `music-shuffle` | Reproductor musical aleatorio |
| `share-send` | Enviar archivos por red |
| `share-get` | Recibir archivos por red |

### Servicios
- **Debian**: Distribución Linux dentro de Termux (proot-distro)
- **Google API**: Integración con rclone y Gmail

### Extras
- **md2pdf**: Convertir Markdown a PDF
- **md2epub**: Convertir Markdown a EPUB
- **md2docx**: Convertir Markdown a DOCX

## Instalación

### Instalador Unificado (Opción A)

```bash
# Clonar repositorio
git clone https://github.com/paragon83114/83114.git

# Ejecutar instalador
cd 83114
bash install.sh
```

### Instalación Manual

```bash
# Instalar stow
pkg install stow -y

# Clonar dotfiles
git clone https://github.com/paragon83114/83114.git
cd 83114

# Desplegar dotfiles con stow
stow --target="$HOME" */

# Copiar scripts y crear symlinks
cp -r scripts "$HOME/"
for f in "$HOME/scripts"/*.sh; do
    ln -sf "$f" "$PREFIX/bin/$(basename "$f" .sh)"
done
```

## Uso

### Menú del Instalador

```bash
bash install.sh
```

```
  INSTALADOR DE TERMUX

  BASE
  [1] Base (Termux + bashrc)
  [2] Scripts (d, music-all, music-shuffle, share-send, share-get, md2pdf, md2epub, md2docx)

  HERRAMIENTAS
  [3] OpenCode (IA CLI)
  [4] Neovim (editor)
  [5] Extras (fzf, zoxide, mpv, yt-dlp)
  [6] mmx-cli (MiniMax AI)

  SERVICIOS
  [7] Tmux (terminal manager)
  [8] Debian (proot-distro)
  [9] Google API (rclone + Gmail)

  TODO
  [T] Instalación completa
```

### Instalar Todo

```bash
# Opción T en el menú
bash install.sh
# Seleccionar T
```

### Instalar por Componente

```bash
# Solo dotfiles
stow --target="$HOME" */

# Solo scripts
cp -r scripts "$HOME/"
chmod +x "$HOME/scripts"/*.sh
```

## Gestión de Dotfiles con Stow

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

Transfirir archivos entre dispositivos en la misma red.

```bash
# Dispositivo emisor (en ~/scripts)
share-send archivo.txt

# Dispositivo receptor
share-get
```

### music-shuffle

```bash
music-shuffle
```

### d

Navegación rápida. Editar `d.sh` para personalizar rutas.

```bash
d
```

## Configuración Post-Instalación

### Termux Setup

```bash
# Configurar almacenamiento
termux-setup-storage

# Recargar configuración
termux-reload-settings
```

### Neovim

```bash
# Instalar plugins
nvim --headless "+Lazy! sync" +qa
```

## Requisitos

- Termux (Android)
- Git
- Stow
- Bash 4+

## Licencia

MIT
