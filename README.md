# Dotfiles

## Etch developer profile

The Etch `developer` profile covers Git, tmux, Homebrew, Starship, Nerd Fonts,
Bash-it, Bash, Zsh, Oh My Zsh, Vim, VS Code, and, on macOS, Ghostty, Zed, workstation and
personal apps, developer tools, and Xcode. Gaming apps are opt-in. The
[Vim plugin audit](docs/vim-plugin-audit.md) records the migration decisions.

```sh
git clone --branch dev https://github.com/rahul0705/dotfiles.git
cd dotfiles
git submodule update --init --recursive vendor/etch modules/tmux/files/plugins/tpm modules/ghostty/files/themes/catppuccin modules/oh-my-zsh/files/custom/plugins/zsh-autosuggestions modules/oh-my-zsh/files/custom/plugins/zsh-completions modules/oh-my-zsh/files/custom/plugins/zsh-syntax-highlighting modules/oh-my-zsh/files/custom/themes/powerlevel9k modules/oh-my-zsh/files/custom/themes/powerlevel10k
./etch                              # preview only
./etch validate
./etch plan --profile developer -v
./etch doctor --profile developer
./etch apply --profile developer --allow-sudo  # needed when Homebrew is absent
if [ "$(uname -s)" = Darwin ]; then
  case "$(uname -m)" in
    arm64) brew_bin=/opt/homebrew/bin/brew ;;
    *) brew_bin=/usr/local/bin/brew ;;
  esac
  eval "$("$brew_bin" shellenv)"
fi
./etch apply --profile developer     # install deferred Homebrew packages
./etch apply --profile developer     # established state should be skipped
```

Python 3.9+, Git, tmux, and Zsh are required. The launcher
uses the pinned Etch source with site packages disabled; no global Etch or
Python package installation is needed. Homebrew and VS Code reference plugins
are explicitly registered from that same pin; Starship and fonts use Homebrew
on macOS.

The Homebrew module runs only on macOS. If `brew` is missing, an Etch-declared
sudo action prompts for a password when needed, then Homebrew's upstream
installer runs as the regular user with `NONINTERACTIVE=1` to skip its
confirmation prompt. `--allow-sudo` is needed only for a new install. On a
fresh macOS machine, the first developer apply skips package actions that
cannot yet find `brew`. Load `brew shellenv` in the calling shell, then apply
the developer profile again to install those packages. Existing Homebrew
installations are left alone.

The Git module owns `.gitconfig`, `.gitignore_global`, and `.gitmessage`.
`tools/vcs/git` remains a temporary alias for existing home links.
Etch creates missing parent directories and may replace different symlinks,
matching the old link defaults. It refuses to overwrite regular files or
directories: review and back up those conflicts before applying. Etch does not
remove links it has not taken ownership of.
Machine-local receipts live in the ignored `.etch/` directory.

Etch's link defaults use `target_match: 'direct'` with `relink: True` during
this migration. An old link such as `~/.gitconfig -> tools/vcs/git/gitconfig`
resolves to the correct file, but its immediate target is the legacy path.
Etch now plans to replace that symlink with one pointing directly to the
module asset; it does not require manually unlinking it first. Review those
changes in `./etch plan --profile developer -v` before applying. Existing
direct links are skipped, and regular files or directories are still refused.
This uses the behavior added for [Etch issue #85](https://github.com/rm-industries/etch/issues/85).

The tmux module owns `~/.tmux` and selects `~/.tmux.conf` using the observed
`tmux -V` version. Tmux 2.1 and newer use the modern mouse settings; older
versions use the legacy settings. The pinned TPM checkout lives under the tmux
module and must be initialized as shown above. `terminals/tmux` remains a
temporary alias for existing home links. Direct target matching relinks home
paths that still point through `terminals/tmux`. Etch runs TPM's installer on
the first apply when tmux is available. TPM installs the plugins listed in
`tmux.conf`; use `~/.tmux/plugins/tpm/bin/install_plugins` after adding plugins
or to repair a partial installation.

The Starship module owns `~/.config/starship.toml`. On macOS it uses the
explicit Homebrew plugin to install the formula if missing; on Linux it runs
Starship's published installer into the default `/usr/local/bin` directory.
The config link can be created before Starship is installed, so it needs no
version gate. Zsh starts Starship when it is available.
`shells/starship` remains a temporary alias. Etch relinks old home links
through it directly during apply.

The fonts module installs Hack and FiraCode Nerd Fonts. On Linux it runs Nerd
Fonts' upstream installer for each font in the user font directory and refreshes
the font cache; on macOS it installs the existing Homebrew font casks. Existing
font files or installed casks are skipped on later applies.

The Bash-it module clones Bash-it and runs its noninteractive setup without
changing `~/.bashrc`. The Bash module then links the existing Bash configuration
and requires Bash-it first. `shells/bash/bashrc` remains a compatibility link
for older home links. Etch relinks an existing `~/.bashrc` through that path
directly to the module asset. Local before/after rc files remain supported.
Deprecated Base16 customization is no longer managed.

The Zsh module links `~/.zprofile` and `~/.zshrc` and starts Starship when
available. The Oh My Zsh module requires Zsh, then runs the upstream installer
noninteractively while preserving the linked rc file, and links the existing
custom plugins and themes. `shells/zsh/zprofile`, `shells/zsh/zshrc`,
and `shells/zsh/oh-my-zsh` remain temporary aliases. Etch relinks
old home links through those paths directly to module assets. Local
before/after rc files remain supported.

The VS Code module installs the macOS cask, links settings and keybindings on
macOS and Linux, and installs extensions through the external VS Code plugin
when `code` is available. Linux users must install VS Code separately.
`editors/vscode` remains a temporary alias for existing home links.

The Vim module links `~/.vim` and `~/.vimrc`, uses Etch's managed `download`
action to place vim-plug from upstream, and installs nine selected plugins on
its first apply.
Fresh installs follow upstream's current `plug.vim` and require network access.
A marker under `~/.local/share/vim/plugged` skips later plugin installs. Use Vim's
`:PlugUpdate`, `:PlugDiff`, and `:PlugClean` for manual plugin maintenance;
Etch does not update plugins on every run. `editors/vim` remains a temporary
alias for existing home links. If an earlier migration run downloaded
`plug.vim` with `curl`,
Etch will refuse to adopt that unmanaged file. Confirm the file at
`~/.local/share/vim/site/autoload/plug.vim` is the earlier vim-plug download,
remove that file, then reapply the Vim module so Etch can own the new download.

On macOS, the developer-tools module installs Go, Node, Python, Rustup, uv,
NVM, GitHub CLI, and Docker Desktop. The workstation module installs Rectangle,
AltTab, MonitorControl, Firefox, and Chrome; personal-apps installs the selected
personal casks. Ghostty and Zed each own their config links. The Xcode module
installs `mas`, then requests Xcode from the Mac App Store only if
`/Applications/Xcode.app` is absent. A fresh download requires a signed-in
Mac App Store account. The opt-in `gaming` module installs the supported gaming
casks with `./etch apply homebrew gaming`; it is not part of `developer`.

### Switching an existing checkout

Update an existing checkout to `dev`:

```sh
git fetch origin dev
git switch dev
git pull --ff-only origin dev
```

Initialize the pinned submodules with the command above, then review
`./etch plan --profile developer -v` before applying. Back up
any regular files at Etch-owned destinations; Etch will refuse to overwrite
them. Review planned relinks from legacy alias paths before applying; no
manual unlinking is needed for those symlinks.

Run the apply sequence above, including the second pass after loading Homebrew
into the shell on a fresh Mac. A final apply should report no changes, and
`./etch doctor --profile developer` should pass.

To inspect the plan with a temporary home:

```sh
test_home=$(mktemp -d)
HOME="$test_home" ./etch plan --profile developer
```

CI validates, plans, and applies the developer profile in an isolated home on
Ubuntu and macOS with Python 3.9 and the latest stable 3.x. Linux CI installs
Vim, tmux, Zsh, and VS Code first because their Linux packages are user-managed;
the profile manages their configuration and extensions. A weekly run checks for
upstream dependency drift even without a dotfiles change. The opt-in gaming
module is outside this profile. macOS runners include Xcode, so CI does not
exercise a fresh Mac App Store download or an interactive GUI session.

## License

This software is hereby released into the public domain. That means you can do
whatever you want with it without restriction. See `LICENSE.md` for details.
