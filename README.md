# Configs

Backup das minhas configurações de terminal (kitty, herdr e zsh) e script para restaurá-las em uma máquina nova.

## Conteúdo

| Arquivo | Destino |
| --- | --- |
| `kitty/kitty.conf` | `~/.config/kitty/kitty.conf` |
| `kitty/current-theme.conf` | `~/.config/kitty/current-theme.conf` (Catppuccin Mocha) |
| `herdr/config.toml` | `~/.config/herdr/config.toml` |
| `zsh/.zshrc` | `~/.zshrc` |
| `zsh/.zsh_aliases` | `~/.zsh_aliases` |
| `settings.json` | Windows Terminal (não é instalado pelo script) |

## Restaurando em uma máquina nova (macOS)

```sh
git clone git@github.com:robersonnaves/Configs.git ~/Dev/Configs
cd ~/Dev/Configs
./restore.sh
```

Depois, abra um novo terminal (ou rode `source ~/.zshrc`) e reinicie o kitty.

O script pode ser executado mais de uma vez: tudo o que já estiver instalado é ignorado.

## O que o `restore.sh` faz

1. **Homebrew**: instala, caso não exista.
2. **Pacotes** usados pelas configs, via Homebrew:

   | Pacote | Para quê |
   | --- | --- |
   | `eza` | aliases `ls`, `l`, `ll`, `la`, `l.` |
   | `midnight-commander` | `mcedit`, definido como `$EDITOR` |
   | `podman` + `docker-compose` | plugin `podman` do oh-my-zsh e aliases `pms`, `pcu`, `pcd`, `docker` |
   | `libpq` | `psql` no `PATH` |
   | `herdr` | multiplexador de agentes |
   | `kitty` (cask) | terminal |
   | `visual-studio-code` (cask) | suffix aliases para `.cs` e `.json` (`code`) |

3. **oh-my-zsh**: instala sem sobrescrever o `.zshrc` (tema `agnoster`, plugins `git` e `podman`).
4. **Fonte** D2CodingLigature Nerd Font, baixada do [nerd-fonts](https://github.com/ryanoasis/nerd-fonts) para `~/Library/Fonts`.
   A versão fica fixada em `v3.4.0` (`NERD_FONTS_VERSION`), porque a partir da v3.5 a família foi renomeada para
   "D2KodingLigature" e deixaria de bater com o `font_family` do `kitty.conf`. Pelo mesmo motivo, a fonte não é instalada pelo cask do Homebrew.
5. **Configs**: copia os arquivos para os destinos. Se já existir um arquivo diferente no destino, ele é salvo antes em
   `~/.config-backup-<data>/`.

## Passos manuais

- `~/.secrets_ai` (variáveis sensíveis carregadas pelo `.zshrc`) não fica no repositório: recrie-o manualmente.
- Ferramentas que só adicionam entradas ao `PATH` no `.zshrc` (LM Studio, Antigravity, mimocode, Kiro, OpenSpec) não são
  instaladas pelo script. Sem elas, as entradas apenas ficam sem efeito.
- Para usar o podman, inicialize a máquina virtual uma vez: `podman machine init` e depois `pms`.

## Atualizando o backup

Depois de alterar alguma config nesta máquina, copie-a de volta para o repositório e faça o commit:

```sh
cp ~/.config/kitty/kitty.conf ~/.config/kitty/current-theme.conf kitty/
cp ~/.config/herdr/config.toml herdr/
cp ~/.zshrc ~/.zsh_aliases zsh/
git add -A && git commit -m "Update configs" && git push
```

Se adicionar uma nova ferramenta às configs, inclua-a em `BREW_FORMULAS` ou `BREW_CASKS` no `restore.sh`.
