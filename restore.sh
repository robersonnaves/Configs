#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d%H%M%S)"
NERD_FONTS_VERSION="v3.4.0"

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
