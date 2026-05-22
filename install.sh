#!/usr/bin/env bash
# Idempotent installer for the dotfiles repo.
# Appends a fenced source block to ~/.bashrc and seeds secrets / local override
# files from their .example templates.

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASHRC="$HOME/.bashrc"
MARK_BEGIN="# >>> dotfiles >>>"
MARK_END="# <<< dotfiles <<<"

# --- Seed secrets.sh (chmod 600) -------------------------------------------
secrets_src="$DOTFILES_DIR/bash/secrets.sh.example"
secrets_dst="$DOTFILES_DIR/bash/secrets.sh"
if [ -f "$secrets_src" ] && [ ! -e "$secrets_dst" ]; then
    cp "$secrets_src" "$secrets_dst"
    chmod 600 "$secrets_dst"
    echo "seeded $secrets_dst (chmod 600)"
fi

# --- Seed 99-local.sh -------------------------------------------------------
local_src="$DOTFILES_DIR/bash/bashrc.d/99-local.sh.example"
local_dst="$DOTFILES_DIR/bash/bashrc.d/99-local.sh"
if [ -f "$local_src" ] && [ ! -e "$local_dst" ]; then
    cp "$local_src" "$local_dst"
    echo "seeded $local_dst"
fi

# --- Append source block to ~/.bashrc if missing ----------------------------
touch "$BASHRC"
if grep -qF "$MARK_BEGIN" "$BASHRC"; then
    echo "marker already present in $BASHRC; skipping append"
else
    {
        printf '\n%s\n' "$MARK_BEGIN"
        printf 'export DOTFILES_DIR="%s"\n' "$DOTFILES_DIR"
        printf '[ -r "$DOTFILES_DIR/bash/bashrc" ] && . "$DOTFILES_DIR/bash/bashrc"\n'
        printf '%s\n' "$MARK_END"
    } >> "$BASHRC"
    echo "appended dotfiles block to $BASHRC"
fi

echo "done. open a new shell or: source $BASHRC"
