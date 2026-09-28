#!/bin/sh
set -eu

plugins_dir="$HOME/.local/share/vim/plugged"
marker="$plugins_dir/.etch-initialized"
# Keep this list in sync with files/plugins.vim.
plugins='vim-signify
vim-better-whitespace
nerdcommenter
vim-indent-guides
tmuxline.vim
catppuccin
vim-airline
vim-fugitive
editorconfig-vim'
test ! -f "$marker" || exit 0

GIT_TERMINAL_PROMPT=0 vim -Nu "$HOME/.vimrc" -i NONE -n -es \
    -c 'PlugInstall --sync' -c 'qa!'

for plugin in $plugins; do
    test -d "$plugins_dir/$plugin/.git" || {
        printf 'vim-plug did not install %s\n' "$plugin" >&2
        exit 1
    }
done

: > "$marker"
