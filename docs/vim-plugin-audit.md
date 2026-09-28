# Vim plugin audit

Issue #81 replaced Vundle with vim-plug without carrying every old plugin
forward. This inventory covers the former `editors/vim/vundles.vim` entries and
four plugin submodules formerly under `editors/vim/pack/`. Decisions reflect Vim's use
for quick terminal edits, with tmux status-line integration retained.

| Former plugin | Decision | Reason |
| --- | --- | --- |
| VundleVim/Vundle.vim | Replace with vim-plug | Use one plugin manager; vendor and pin `plug.vim` in the Vim module. |
| mhinz/vim-signify | Keep | Git change signs are configured for this repo. |
| tmux-plugins/vim-tmux | Remove | Current Vim provides tmux syntax and filetype support; the plugin's extra commands are not needed for quick edits. |
| tmux-plugins/vim-tmux-focus-events | Use native Vim | [Upstream says it is obsolete](https://github.com/tmux-plugins/vim-tmux-focus-events) with Vim 8.2.2345 and newer. |
| andreshazard/vim-logreview | Remove | No local configuration or current log-review workflow depends on it. |
| godlygeek/tabular | Remove | Markdown/table editing is not part of the current Vim workflow. |
| plasticboy/vim-markdown | Use native Vim | Current Vim includes Markdown syntax; no plugin-specific settings are used. |
| ntpeters/vim-better-whitespace | Keep | Existing settings highlight whitespace and strip trailing whitespace on save. |
| scrooloose/nerdcommenter | Keep | Several custom comment rules are configured; use its current `preservim/nerdcommenter` repository. |
| jeffkreeftmeijer/vim-numbertoggle | Use native Vim | Small insert-mode autocommands can preserve the number toggle alongside the existing `number` and `relativenumber` settings. |
| nathanaelkane/vim-indent-guides | Keep | Indent guides are explicitly enabled in current settings. |
| scrooloose/syntastic | Remove | The project is archived, and Vim linting is no longer wanted. |
| pearofducks/ansible-vim | Remove | Ansible-specific editing is no longer needed. |
| edkolev/tmuxline.vim | Keep | The tmux status-line integration is still used. |
| catppuccin/vim (submodule) | Keep via vim-plug | The active Vim colorscheme uses it. |
| vim-airline/vim-airline (submodule) | Keep via vim-plug | Its theme and tmuxline integration are configured. |
| tpope/vim-fugitive (submodule) | Keep via vim-plug | Retain the maintained Git commands for occasional terminal work. |
| editorconfig/editorconfig-vim (submodule) | Keep via vim-plug | Preserve project EditorConfig behavior when editing without VS Code. |

The stale Vimwiki setting was removed; the unrelated `sudo-write.vim` setting
was kept.

The Vim module vendors pinned `plug.vim` and declares the nine retained plugins.
After the first successful Etch apply installs them, a marker skips later
installs. Routine upgrades and removals remain manual through `:PlugUpdate`,
`:PlugDiff`, and `:PlugClean`. Vundle and its old plugin submodules were removed
after an isolated first and second Etch apply verified the replacement.
