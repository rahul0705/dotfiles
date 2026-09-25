# Dotfiles

## Etch migration (issue #81)

The migration is being reviewed in small PRs targeting `dev`. The incremental
Etch `developer` profile currently covers Git, tmux, Starship, Nerd Fonts and
Bash-it, Bash and Zsh; it does not yet replace the existing macOS/Linux Dotbot profiles.

```sh
git clone --branch dev https://github.com/rahul0705/dotfiles.git
cd dotfiles
git submodule update --init --recursive vendor/etch modules/tmux/files/plugins/tpm modules/zsh/files/oh-my-zsh/custom/plugins/zsh-autosuggestions modules/zsh/files/oh-my-zsh/custom/plugins/zsh-completions modules/zsh/files/oh-my-zsh/custom/plugins/zsh-syntax-highlighting modules/zsh/files/oh-my-zsh/custom/themes/powerlevel9k modules/zsh/files/oh-my-zsh/custom/themes/powerlevel10k
./etch                              # preview only
./etch plan --profile developer -v
./etch doctor --profile developer
./etch apply --profile developer
./etch apply --profile developer     # established links should be skipped
```

Python 3.9+, Git, tmux, and Zsh are required. The launcher
uses the pinned Etch source with site packages disabled; no global Etch or
Python package installation is needed. Homebrew and VS Code reference plugins
are explicitly registered from that same pin; Starship and fonts use Homebrew
on macOS.

The Git module owns `.gitconfig`, `.gitignore_global`, and `.gitmessage`.
`tools/vcs/git` remains a compatibility link, so existing home links and Dotbot's
`install-profile` / `install-standalone git` continue to use the same files.
Etch creates missing parent directories and may replace different symlinks,
matching the old link defaults. It refuses to overwrite regular files or
directories: review and back up those conflicts before applying. Broad Dotbot
cleanup is not migrated; Etch must have ownership receipts before removing links.
Machine-local receipts live in the ignored `.etch/` directory.

The tmux module owns `~/.tmux` and selects `~/.tmux.conf` using the observed
`tmux -V` version. Tmux 2.1 and newer use the modern mouse settings; older
versions use the legacy settings. The pinned TPM checkout lives under the tmux
module and must be initialized as shown above. `terminals/tmux` remains a
compatibility link for existing Dotbot installations. Etch considers legacy
links that resolve to the same files satisfied, so it leaves their literal
targets untouched. To have Etch recreate and record ownership of those links,
first inspect them with `ls -l ~/.tmux ~/.tmux.conf`, unlink only links that
point to the legacy `terminals/tmux` path, then apply the tmux module. TPM's
third-party plugins are still installed separately with its existing
`~/.tmux/plugins/tpm/bin/install_plugins` command; the Etch tmux module does
not fetch them during apply.

The Starship module owns `~/.config/starship.toml`. On macOS it uses the
explicit Homebrew plugin to install the formula if missing; on Linux it runs
Starship's published installer into the default `/usr/local/bin` directory.
Both installers refresh a shared PATH-based version fact so a missing Starship
can activate its config link in the same apply. Shell setup will be handled in
a later slice. `shells/starship` remains a compatibility link
for Dotbot. As with tmux, an old symlink that resolves through this path is
already satisfied to Etch; inspect and unlink that symlink before applying if
you want Etch to recreate and own it directly.

The fonts module installs Hack and FiraCode Nerd Fonts. On Linux it runs Nerd
Fonts' upstream installer for each font in the user font directory and refreshes
the font cache; on macOS it installs the existing Homebrew font casks. Existing
font files or installed casks are skipped on later applies.

The Bash-it module clones Bash-it and runs its noninteractive setup without
changing `~/.bashrc`. The Bash module then links the existing Bash configuration
and requires Bash-it first. `shells/bash/bashrc` remains a compatibility link
for Dotbot. Etch may leave an existing `~/.bashrc` link through that path in
place if it resolves to the same file. To have Etch own the direct link,
inspect and unlink that legacy link before applying. Local before/after rc
files remain supported. Deprecated Base16 customization remains only in the
original Dotbot tree and is not part of these modules.

The Zsh module clones Oh My Zsh without changing the login shell or generating
a new rc file, links the existing custom plugins and themes, then links
`~/.zprofile` and `~/.zshrc`. It requires Starship, which the rc file starts.
`shells/zsh/zprofile`, `shells/zsh/zshrc`, and `shells/zsh/oh-my-zsh` remain compatibility links for
Dotbot. Etch may consider old home links through those paths satisfied; inspect
and unlink only those legacy links before applying if you want Etch to own
direct links. Local before/after rc files remain supported.

To try this slice without changing your home:

```sh
test_home=$(mktemp -d)
HOME="$test_home" ./etch plan --profile developer
HOME="$test_home" ./etch apply --profile developer
HOME="$test_home" ./etch apply --profile developer
```

The Git slice passed on macOS 27.0, arm64, with Python 3.14.7 in temporary
homes, and its CI checks passed on Linux and macOS with Python 3.9 and 3.14.
The expanded CI runs Etch with Git, tmux, Starship, fonts and Bash-it on those
runners, inspects their installed links, Bash and Zsh startup, binaries and font packages, and confirms the
second apply makes no changes. Linux starts without Starship, checks the
deferred config link in the initial plan, and installs the current release.
It simulates tmux 2.0 to inspect the legacy selection; it does not run an old
tmux binary or install third-party TPM plugins.

Subsequent review slices will cover the remaining modules, platform profiles
and real platform evidence.
Issue #81 stays open until those acceptance criteria are verified.

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
