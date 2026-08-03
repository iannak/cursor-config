#!/usr/bin/env bash
# Instala a configuração do Cursor deste repositório.
#
#   ./install.sh global              symlink de agents/skills/commands em ~/.cursor
#   ./install.sh project [caminho]   copia rules + AGENTS.md para um projeto
#   ./install.sh status              mostra o que está instalado
#
# Nada é sobrescrito sem --force.

set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FORCE=0
ARGS=()
for arg in "$@"; do
  if [[ "$arg" == "--force" ]]; then FORCE=1; else ARGS+=("$arg"); fi
done
set -- ${ARGS+"${ARGS[@]}"}

info() { printf '  \033[32m✓\033[0m %s\n' "$1"; }
warn() { printf '  \033[33m!\033[0m %s\n' "$1"; }

# Cria symlink em $2 apontando para $1, preservando o que já existe.
link() {
  local from="$1" to="$2"
  if [[ -L "$to" ]]; then
    local current
    current="$(readlink -f "$to")"
    if [[ "$current" == "$(readlink -f "$from")" ]]; then
      info "já linkado: $to"
      return
    fi
    if (( FORCE )); then
      rm "$to"
    else
      warn "existe e aponta para outro lugar: $to  (use --force)"
      return
    fi
  elif [[ -e "$to" ]]; then
    if (( FORCE )); then
      mv "$to" "$to.bak.$$"
      warn "backup: $to.bak.$$"
    else
      warn "já existe (não é symlink): $to  (use --force)"
      return
    fi
  fi
  ln -s "$from" "$to"
  info "linkado: $to -> $from"
}

install_global() {
  local dest="$HOME/.cursor"
  mkdir -p "$dest"
  echo "Instalando em $dest"
  local d
  for d in agents skills commands; do
    [[ -d "$SRC/.cursor/$d" ]] && link "$SRC/.cursor/$d" "$dest/$d"
  done
  echo
  echo "Rules (.cursor/rules) são por projeto — rode: ./install.sh project <caminho>"
}

install_project() {
  local target="${1:-$PWD}"
  target="$(cd "$target" && pwd)"
  echo "Instalando em $target"
  mkdir -p "$target/.cursor"

  if [[ -e "$target/.cursor/rules" && ! -L "$target/.cursor/rules" ]] && (( ! FORCE )); then
    warn "$target/.cursor/rules já existe — copiando só os arquivos que faltam"
    mkdir -p "$target/.cursor/rules"
    local f
    for f in "$SRC"/.cursor/rules/*.mdc; do
      local base; base="$(basename "$f")"
      if [[ -e "$target/.cursor/rules/$base" ]]; then
        warn "mantido: .cursor/rules/$base"
      else
        cp "$f" "$target/.cursor/rules/$base"
        info "copiado: .cursor/rules/$base"
      fi
    done
  else
    mkdir -p "$target/.cursor/rules"
    cp "$SRC"/.cursor/rules/*.mdc "$target/.cursor/rules/"
    info "rules copiadas para .cursor/rules/"
  fi

  if [[ -e "$target/AGENTS.md" ]] && (( ! FORCE )); then
    warn "AGENTS.md já existe — não sobrescrito"
  else
    cp "$SRC/AGENTS.md" "$target/AGENTS.md"
    info "AGENTS.md copiado (preencha a seção 'Projeto')"
  fi
}

status() {
  local d
  echo "Global (~/.cursor):"
  for d in agents skills commands; do
    if [[ -L "$HOME/.cursor/$d" ]]; then
      info "$d -> $(readlink -f "$HOME/.cursor/$d")"
    elif [[ -d "$HOME/.cursor/$d" ]]; then
      warn "$d existe, mas não é symlink deste repo"
    else
      warn "$d não instalado"
    fi
  done
}

case "${1:-}" in
  global)  install_global ;;
  project) install_project "${2:-$PWD}" ;;
  status)  status ;;
  *)       sed -n '2,9p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//' ; exit 1 ;;
esac
