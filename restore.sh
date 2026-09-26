#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d%H%M%S)"
NERD_FONTS_VERSION="v3.4.0"

# ferramentas usadas pelas configs
BREW_FORMULAS=(
  "eza:eza"                       # aliases ls/l/ll/la (.zsh_aliases)
  "midnight-commander:mcedit"     # mcedit, usado como $EDITOR (.zshrc)
  "podman:podman"                 # plugin podman do oh-my-zsh e aliases pms/pcu/pcd/docker
  "docker-compose:docker-compose" # backend do "podman compose"
  "libpq:psql"                    # psql (PATH em .zshrc)
  "herdr:herdr"                   # herdr/config.toml
)
BREW_CASKS=(
  "kitty:kitty.app"                             # kitty/*.conf
  "visual-studio-code:Visual Studio Code.app"   # suffix aliases -s cs/json (code)
)

install_homebrew() {
  if command -v brew >/dev/null 2>&1; then
    return
  fi
  if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    return
  fi
  echo "instalando homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
}

install_packages() {
  local entry formula bin cask app
  for entry in "${BREW_FORMULAS[@]}"; do
    formula="${entry%%:*}" bin="${entry#*:}"
    # binario instalado por outro meio (ex.: instalador oficial do podman) conta como instalado
    if brew list --formula "$formula" >/dev/null 2>&1 || command -v "$bin" >/dev/null 2>&1 \
      || [ -x "$(brew --prefix)/opt/$formula/bin/$bin" ]; then
      echo "ja instalado: $formula"
    else
      echo "instalando: $formula"
      brew install "$formula"
    fi
  done

  for entry in "${BREW_CASKS[@]}"; do
    cask="${entry%%:*}" app="${entry#*:}"
    # app instalado fora do homebrew faria o "brew install --cask" falhar
    if brew list --cask "$cask" >/dev/null 2>&1 || [ -d "/Applications/$app" ]; then
      echo "ja instalado: $cask"
    else
      echo "instalando: $cask"
      brew install --cask "$cask"
    fi
  done
}

install_oh_my_zsh() {
  # tema agnoster e plugins git/podman usados no .zshrc
  if [ -d "$HOME/.oh-my-zsh" ]; then
    echo "ja instalado: oh-my-zsh"
    return
  fi
  echo "instalando: oh-my-zsh"
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
}

install_file() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"

  if [ -e "$dst" ] && ! cmp -s "$src" "$dst"; then
    mkdir -p "$BACKUP_DIR/$(dirname "${dst#"$HOME"/}")"
    cp "$dst" "$BACKUP_DIR/${dst#"$HOME"/}"
    echo "backup: $dst -> $BACKUP_DIR/${dst#"$HOME"/}"
  fi

  cp "$src" "$dst"
  echo "instalado: $dst"
}

install_font() {
  # fonte usada no kitty (font_family "D2CodingLigature Nerd Font Mono")
  local font_name="D2CodingLigature Nerd Font Mono"
  local font_dir
  case "$(uname -s)" in
    Darwin) font_dir="$HOME/Library/Fonts" ;;
    *)      font_dir="$HOME/.local/share/fonts" ;;
  esac

  if ls "$font_dir"/D2CodingLigatureNerdFontMono-*.ttf >/dev/null 2>&1 \
    || ls /Library/Fonts/D2CodingLigatureNerdFontMono-*.ttf >/dev/null 2>&1; then
    echo "fonte ja instalada: $font_name"
    return
  fi

  # versao fixada: a partir da v3.5 a familia foi renomeada para "D2KodingLigature",
  # o que nao casaria com o font_family do kitty.conf (o cask do homebrew ja usa a nova)
  echo "baixando fonte: $font_name (nerd-fonts $NERD_FONTS_VERSION)"
  local tmp
  tmp="$(mktemp -d)"
  curl -fsSL -o "$tmp/D2Coding.zip" \
    "https://github.com/ryanoasis/nerd-fonts/releases/download/$NERD_FONTS_VERSION/D2Coding.zip"
  mkdir -p "$font_dir"
  unzip -o -q "$tmp/D2Coding.zip" '*.ttf' -d "$font_dir"
  rm -rf "$tmp"
  if command -v fc-cache >/dev/null 2>&1; then fc-cache -f "$font_dir"; fi
  echo "fonte instalada: $font_name"
}

if [ "$(uname -s)" = "Darwin" ]; then
  install_homebrew
  install_packages
else
  echo "aviso: instalacao de pacotes suportada apenas no macOS; instale manualmente: eza midnight-commander podman docker-compose libpq herdr kitty"
fi
install_oh_my_zsh
install_font

install_file "$REPO_DIR/herdr/config.toml"         "$HOME/.config/herdr/config.toml"
install_file "$REPO_DIR/kitty/kitty.conf"           "$HOME/.config/kitty/kitty.conf"
install_file "$REPO_DIR/kitty/current-theme.conf"   "$HOME/.config/kitty/current-theme.conf"
install_file "$REPO_DIR/zsh/.zshrc"                 "$HOME/.zshrc"
install_file "$REPO_DIR/zsh/.zsh_aliases"           "$HOME/.zsh_aliases"

if [ -d "$BACKUP_DIR" ]; then
  echo ""
  echo "arquivos anteriores preservados em: $BACKUP_DIR"
fi

echo ""
echo "restauracao concluida. abra um novo terminal (ou rode 'source ~/.zshrc') para aplicar o zsh."
