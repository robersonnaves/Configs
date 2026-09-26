#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d%H%M%S)"

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

install_file "$REPO_DIR/herdr/config.toml"          "$HOME/.config/herdr/config.toml"
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
