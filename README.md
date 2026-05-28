# 83114 - Instalador Unificado de Termux

Sistema de instalación y gestión de dotfiles para Termux usando GNU Stow.

## Estructura

```
83114/
├── install.sh          # Instalador interactivo
├── scripts/            # Scripts utilitarios
│   ├── d.sh           # Diario personal
│   ├── gmail-check.sh # Verificar correos no leidos
│   ├── music-select.sh # Seleccionar y reproducir musica
│   ├── music-shuffle.sh # Reproductor musical aleatorio
│   ├── share-send.sh  # Enviar archivos
│   └── share-get.sh   # Recibir archivos
├── templates/         # Plantillas
│   └── daily.md       # Plantilla del diario
└── dotfiles/          # Configuraciones (stow)
    ├── bashrc/.bashrc
    ├── tmux/.tmux.conf
    ├── termux/.termux/
    │    ├── termux.properties
    │    └── fonts/font.ttf   # Fuente personalizada
    ├── atuin/.config/atuin/config.toml
    └── nvim/.config/nvim/
        └── lua/plugins/
            └── catppuccin.lua  # Tema Catppuccin Mocha
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
  - catppuccin.lua: Tema Catppuccin Mocha
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
| `d` | Ver diario personal con glow |
| `d "texto"` | Añadir entrada al diario |
| `d eval` | Procesar diario con IA |
| `d del` | Borrar última entrada |
| `gmail-check` | Correos no leidos en Gmail |
| `music-select` | Seleccionar y reproducir musica |
| `music-shuffle` | Reproductor musical aleatorio |
| `share-send` | Enviar archivos por red |
| `share-get` | Recibir archivos por red |
| `md2pdf/md2epub/md2docx` | Convertir Markdown a PDF/EPUB/DOCX |

### Alias
| Alias | Comando |
|-------|---------|
| `ls` | lsd |
| `l` | lsd -l |
| `ll` | lsd -lha |
| `c` | clear |
| `v` | nvim |
| `g` | glow -w220 -p |
| `oc` | opencode -c |
| `t` | lsd -l --tree --depth 2 |
| `m` | music-shuffle |
| `ms` | music-select |
| `lg` | lazygit (en ~/termux) |
| `bye` | kill -9 -1 |

### Funciones
| Función | Descripción |
|---------|-------------|
| `google <texto>` | Buscar en Google |
| `minimax <query>` | Buscar con MiniMax AI |

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

# Crear symlinks de scripts en $PREFIX/bin
for f in scripts/*.sh; do
    ln -sf "$(pwd)/$f" "$PREFIX/bin/$(basename "$f" .sh)"
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
  [2] Scripts (d, gmail-check, music-select, music-shuffle, share-send, share-get, md2pdf, md2epub, md2docx)

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

# Solo scripts (symlinks a PREFIX/bin)
for f in scripts/*.sh; do
    ln -sf "$(pwd)/$f" "$PREFIX/bin/$(basename "$f" .sh)"
done
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

Diario personal. Sin args: ver con glow. Con args: añadir entrada.

```bash
d                  # Ver diario
d "texto"          # Añadir entrada
d eval             # Procesar con IA
d del              # Borrar última entrada
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
