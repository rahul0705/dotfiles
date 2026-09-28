# Dotfiles

## Etch migration (issue #81)

The migration is being reviewed in small PRs targeting `dev`. The Etch
`developer` profile covers Git, tmux, Homebrew, Starship, Nerd Fonts, Bash-it,
Bash, Zsh, Oh My Zsh, Vim, VS Code, and, on macOS, Ghostty, Zed, workstation and
personal apps, developer tools, and Xcode. Gaming apps are opt-in. The
[Vim plugin audit](docs/vim-plugin-audit.md) records the migration decisions.
The original macOS/Linux Dotbot profiles remain available during switch-over.

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
`tools/vcs/git` remains a compatibility link, so existing home links and Dotbot's
`install-profile` / `install-standalone git` continue to use the same files.
Etch creates missing parent directories and may replace different symlinks,
matching the old link defaults. It refuses to overwrite regular files or
directories: review and back up those conflicts before applying. Broad Dotbot
cleanup is not migrated; Etch must have ownership receipts before removing links.
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
compatibility link for existing Dotbot installations. Direct target matching
relinks home paths that still point through `terminals/tmux`. TPM's
third-party plugins are still installed separately with its existing
`~/.tmux/plugins/tpm/bin/install_plugins` command; the Etch tmux module does
not fetch them during apply.

The Starship module owns `~/.config/starship.toml`. On macOS it uses the
explicit Homebrew plugin to install the formula if missing; on Linux it runs
Starship's published installer into the default `/usr/local/bin` directory.
The config link can be created before Starship is installed, so it needs no
version gate. Zsh starts Starship when it is available.
`shells/starship` remains a compatibility link
for Dotbot. An old home link through this path is relinked directly during
apply.

The fonts module installs Hack and FiraCode Nerd Fonts. On Linux it runs Nerd
Fonts' upstream installer for each font in the user font directory and refreshes
the font cache; on macOS it installs the existing Homebrew font casks. Existing
font files or installed casks are skipped on later applies.

The Bash-it module clones Bash-it and runs its noninteractive setup without
changing `~/.bashrc`. The Bash module then links the existing Bash configuration
and requires Bash-it first. `shells/bash/bashrc` remains a compatibility link
for Dotbot. Etch relinks an existing `~/.bashrc` through that path directly
to the module asset. Local before/after rc files remain supported. Deprecated
Base16 customization remains only in the original Dotbot tree and is not part
of these modules.

The Zsh module links `~/.zprofile` and `~/.zshrc` and starts Starship when
available. The Oh My Zsh module requires Zsh, then runs the upstream installer
noninteractively while preserving the linked rc file, and links the existing
custom plugins and themes. `shells/zsh/zprofile`, `shells/zsh/zshrc`,
and `shells/zsh/oh-my-zsh` remain compatibility links for Dotbot. Etch relinks
old home links through those paths directly to module assets. Local
before/after rc files remain supported.

The VS Code module installs the macOS cask, links settings and keybindings on
macOS and Linux, and installs extensions through the external VS Code plugin
when `code` is available. Linux users must install VS Code separately.
`editors/vscode` remains a compatibility link for the Dotbot profiles.

The Vim module links `~/.vim` and `~/.vimrc`, and installs nine selected plugins
with the vendored, pinned vim-plug manager on its first apply. A marker under
`~/.local/share/vim/plugged` skips installation on later applies. Use Vim's
`:PlugUpdate`, `:PlugDiff`, and `:PlugClean` for manual plugin maintenance;
Etch does not update plugins on every run. `editors/vim` remains a compatibility
link for `./install-standalone vim` and existing Dotbot links.

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
`./etch doctor --profile developer` should pass. Avoid running the full Dotbot
profile after Etch has taken ownership of its links. Keep the legacy bootstrap
available until the switch-over is verified on your machines.

To inspect the plan with a temporary home:

```sh
test_home=$(mktemp -d)
HOME="$test_home" ./etch plan --profile developer
```

CI runs the developer profile on Linux and macOS with Python 3.9 and 3.14. It
inspects installed links, Vim plugins, packages, extensions, shell startup, and the
idempotent second apply. Linux starts without Starship and verifies its
installation; CI also simulates tmux 2.0 to inspect the legacy selection.
macOS runners already include Xcode, so CI verifies its presence but does not
exercise a fresh Mac App Store download. Issue #81 stays open until the final
switch-over is verified.

## Original Dotbot setup

This is a template repository for bootstrapping your dotfiles with [Dotbot][dotbot].

To get started, you can [fork][fork] this repository (and probably delete this
README and rename your version to something like just `dotfiles`).

In general, you should be using symbolic links for everything, and using git
submodules whenever possible.

To keep submodules at their proper versions, you could include something like
`git submodule update --init --recursive` in your `install.conf.yaml`.

To upgrade your submodules to their latest versions, you could periodically run
`git submodule update --init --remote`.

## Inspiration

If you're looking for inspiration for how to structure your dotfiles or what
kinds of things you can include, you could take a look at some repos using
Dotbot.

If you're using Dotbot and you'd like to include a link to your dotfiles here
as an inspiration to others, please submit a pull request.

## License

This software is hereby released into the public domain. That means you can do
whatever you want with it without restriction. See `LICENSE.md` for details.

That being said, I would appreciate it if you could maintain a link back to
Dotbot (or this repository) to help other people discover Dotbot.

[dotbot]: https://github.com/anishathalye/dotbot
[fork]: https://github.com/anishathalye/dotfiles_template/fork
[anishathalye_dotfiles]: https://github.com/anishathalye/dotfiles
[csivanich_dotfiles]: https://github.com/csivanich/dotfiles
[m45t3r_dotfiles]: https://github.com/m45t3r/dotfiles
[alexwh_dotfiles]: https://github.com/alexwh/dotfiles
[azd325_dotfiles]: https://github.com/Azd325/dotfiles
[bluekeys_dotfiles]: https://github.com/bluekeys/.dotfiles
[wazery_dotfiles]: https://github.com/wazery/dotfiles
[thirtythreeforty_dotfiles]: https://github.com/thirtythreeforty/dotfiles
[dotbot-users]: https://github.com/anishathalye/dotbot/wiki/Users
