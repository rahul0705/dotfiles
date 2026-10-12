# Dotfiles

## Etch developer profile

The Etch `developer` profile covers Git, tmux, Homebrew, Starship, Nerd Fonts,
Bash-it, Bash, Zsh, Oh My Zsh, Vim, VS Code, Codex guidance, and, on macOS, Ghostty, Zed, workstation and
personal apps, developer tools, and Xcode. Gaming apps are opt-in. The
[Vim plugin audit](docs/vim-plugin-audit.md) records the migration decisions.

```sh
git clone https://github.com/rahul0705/dotfiles.git
cd dotfiles
git submodule update --init --recursive modules/codex/files/upstream vendor/etch modules/tmux/files/plugins/tpm modules/ghostty/files/themes/catppuccin modules/oh-my-zsh/files/custom/plugins/zsh-autosuggestions modules/oh-my-zsh/files/custom/plugins/zsh-completions modules/oh-my-zsh/files/custom/plugins/zsh-syntax-highlighting modules/oh-my-zsh/files/custom/themes/powerlevel9k modules/oh-my-zsh/files/custom/themes/powerlevel10k
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
Etch creates missing parent directories and may replace different symlinks,
using `target_match: 'direct'` with `relink: True`. It refuses to overwrite
regular files or directories: review and back up those conflicts before
applying. Etch does not remove links it has not taken ownership of.
Machine-local receipts live in the ignored `.etch/` directory.

The tmux module owns `~/.tmux` and selects `~/.tmux.conf` using the observed
`tmux -V` version. Tmux 2.1 and newer use the modern mouse settings; older
versions use the legacy settings. The pinned TPM checkout lives under the tmux
module and must be initialized as shown above. Etch runs TPM's installer on
the first apply when tmux is available. TPM installs the plugins listed in
`tmux.conf`; use `~/.tmux/plugins/tpm/bin/install_plugins` after adding plugins
or to repair a partial installation.

The Starship module owns `~/.config/starship.toml`. On macOS it uses the
explicit Homebrew plugin to install the formula if missing; on Linux it runs
Starship's published installer into the default `/usr/local/bin` directory.
The config link can be created before Starship is installed, so it needs no
version gate. Zsh starts Starship when it is available.

The fonts module installs Hack and FiraCode Nerd Fonts. On Linux it runs Nerd
Fonts' upstream installer for each font in the user font directory and refreshes
the font cache; on macOS it installs the existing Homebrew font casks. Existing
font files or installed casks are skipped on later applies.

The Bash-it module clones Bash-it and runs its noninteractive setup without
changing `~/.bashrc`. The Bash module then links the existing Bash configuration
and requires Bash-it first. Local before/after rc files remain supported.
Deprecated Base16 customization is no longer managed.

The Zsh module links `~/.zprofile` and `~/.zshrc` and starts Starship when
available. The Oh My Zsh module requires Zsh, then runs the upstream installer
noninteractively while preserving the linked rc file, and links the existing
custom plugins and themes. Local before/after rc files remain supported.

The VS Code module installs the macOS cask, links settings and keybindings on
macOS and Linux, and installs extensions through the external VS Code plugin
when `code` is available. Linux users must install VS Code separately.

The Vim module links `~/.vim` and `~/.vimrc`, uses Etch's managed `download`
action to place vim-plug from upstream, and installs nine selected plugins on
its first apply.
Fresh installs follow upstream's current `plug.vim` and require network access.
A marker under `~/.local/share/vim/plugged` skips later plugin installs. Use Vim's
`:PlugUpdate`, `:PlugDiff`, and `:PlugClean` for manual plugin maintenance;
Etch does not update plugins on every run. If an earlier migration run
downloaded `plug.vim` with `curl`, Etch will refuse to adopt that unmanaged
file. Confirm the file at
`~/.local/share/vim/site/autoload/plug.vim` is the earlier vim-plug download,
remove that file, then reapply the Vim module so Etch can own the new download.

On macOS, the developer-tools module installs Go, Node, Python, Rustup, uv,
NVM, GitHub CLI, and Docker Desktop. The workstation module installs Rectangle,
AltTab, MonitorControl, Firefox, and Chrome, plus Vorssaint on Apple silicon
(macOS 14 or later); personal-apps installs the selected
personal casks. Ghostty and Zed each own their config links. The Xcode module
installs `mas`, then requests Xcode from the Mac App Store only if
`/Applications/Xcode.app` is absent. A fresh download requires a signed-in
Mac App Store account. The opt-in `gaming` module installs the supported gaming
casks with `./etch apply homebrew gaming`; it is not part of `developer`.

### Switching an existing checkout

Update an existing checkout to `main`:

```sh
git fetch origin main
git switch main
git pull --ff-only origin main
```

Initialize the pinned submodules with the command above, then review
`./etch plan --profile developer -v` before applying. Back up
any regular files at Etch-owned destinations; Etch will refuse to overwrite
them.

The old `editors/`, `shells/`, `terminals/`, and `tools/vcs/git` compatibility
aliases have been removed; configuration assets now live under `modules/`.
Home symlinks from a Dotbot-era checkout may become dangling after updating.
Review the plan, then apply the developer profile to replace them with direct
module links. Etch can relink dangling symlinks without manually unlinking them;
regular files and directories still require a backup and explicit handling.

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

## Codex configuration

The `codex` module links global working preferences to `~/.codex/AGENTS.md`
and a portable named profile to `~/.codex/dotfiles.config.toml`. It is included
in the developer profile and can also be applied with `./etch apply codex`.
Codex installation is user-managed. Global guidance applies to new Codex sessions;
select the optional macOS settings with `codex --profile dotfiles`.

Existing regular files are not overwritten. Before the first apply, review and
back up a conflicting `~/.codex/AGENTS.md` or `dotfiles.config.toml`, then move
it out of the destination. Retain any personal guidance you still need.
An existing `AGENTS.override.md` takes precedence over the managed guidance.

Dependabot proposes updates for all repository submodules, including the
Ponytail and Caveman sources.
These track upstream branch commits rather than only tagged releases; review
and merge the update PRs to advance the pins.

The module links individually pinned upstream Ponytail and Caveman skills to
`~/.agents/skills/`. Initialize their sources with:

```sh
git submodule update --init --recursive modules/codex/files/upstream
./etch apply codex
```

Other installed skills are preserved. Avoid enabling both these links and the
same skills through a plugin installation, which can produce duplicate entries.
The core skills are available in new sessions on macOS. Global guidance asks
the agent to apply Ponytail by default to coding tasks when available; Caveman
remains opt-in for terse or compressed communication. Activation is driven by
instructions rather than a configuration switch.
Their upstream licenses remain in the pinned source checkouts.

The guidance file is deployed on both macOS and Linux. Skill links, the named
profile, uv, RTK, Serena, and Codebase Memory are macOS-only. This module
installs no tools on Linux. On macOS, uv comes from Homebrew, matching
developer-tools; both modules can ensure the same formula is present without
creating separate installations. RTK also comes from Homebrew.
uv installs Serena and Codebase Memory in isolated tool environments; Codebase Memory’s first
launch downloads and verifies the matching native release. Existing binaries
satisfying presence checks are preserved rather than upgraded automatically.
The Codebase Memory package avoids its upstream install command, which edits
shell profiles and stops active sessions. The guidance uses `rtk` on PATH
when available. Add `~/.local/bin` to PATH to invoke standalone tools by name.

Create `~/.codex/AGENTS.local.md` for machine-specific guidance, analogous to
the optional Bash/Zsh local customization files. Etch never creates, links,
changes, or commits this file; it lives outside the repository. For example:

```markdown
# Local preferences

- Follow my employer's package-installation policy on this machine.
```

The managed guidance asks the agent to read that file when present. This is an
instruction to the agent, not a native Markdown include: Codex does not
implicitly concatenate `AGENTS.local.md`. Local preferences override managed
global defaults; repository guidance overrides both. With a custom `CODEX_HOME`,
put the local file there. Restart the session after changing guidance.

Select `codex --profile dotfiles` to load the managed Serena and Codebase Memory
MCP definitions. Serena starts from the executable installed by uv, using the
upstream-recommended Python 3.13 environment. In the desktop app,
activate the working repository explicitly if the process starts elsewhere.
Upgrade the installed tools explicitly:

```sh
brew upgrade uv rtk
uv tool upgrade serena-agent codebase-memory-mcp
```

Etch ensures presence rather than upgrading on each apply. New uv installations
use the current package releases; skill source updates remain reviewable
Dependabot PRs. Restart agent sessions after upgrading MCP tools.

The profile's definitions replace same-named server launch settings for that
profile while preserving the base `config.toml`. The module does not unregister
old servers or remove an existing installation of another manager.

Project trust, other MCP servers, plugins, hooks, approval rules, credentials,
sessions, and caches stay local. See the official
[guidance documentation](https://learn.chatgpt.com/docs/agent-configuration/agents-md)
and [configuration precedence](https://learn.chatgpt.com/docs/config-file/config-basic).

### Codex guidance sources

The global guidance distills these engineering articles into task-proportional
defaults. Repository guidance takes precedence. The links are kept here rather
than in the loaded agents file; routine tasks do not require website access.

- [Code Reviews](https://www.rahulmohandas.com/blog/2018-10-08-peer-reviews/)
- [Did You Fix the Bug—or Just Move It?](https://www.rahulmohandas.com/blog/2026-08-20-did-you-fix-the-bug/)
- [Duplication Is Cheaper Than the Wrong Abstraction](https://www.rahulmohandas.com/blog/2026-08-17-duplication-vs-coupling/)
- [The Best Code Is Sometimes the Code You Don't Write](https://www.rahulmohandas.com/blog/2026-09-14-the-best-code-you-dont-write/)
- [Make the Wrong Thing Hard to Do](https://www.rahulmohandas.com/blog/2026-09-30-make-the-wrong-thing-hard-to-do/)

Commit guidance follows the repository's conventions and configured Git
`commit.template` first. This project's template is managed by the Git module
in [gitmessage](modules/git/files/gitmessage); other repositories need not share
its path or format.

## GitLab CI

[GitLab CI](docs/gitlab-ci.md) mirrors the Linux portion of the GitHub compatibility matrix and
workflow linters on the Free tier. macOS coverage remains on GitHub. See the setup notes for the weekly
schedule, and GitHub-specific security checks that remain on GitHub.
