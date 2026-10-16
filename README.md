# Dotfiles

## Etch developer profile

The Etch `developer` profile covers Git, tmux, Homebrew, Starship, Nerd Fonts,
Bash, Oh My Bash, Zsh, Oh My Zsh, Vim, VS Code, Codex guidance, and, on macOS, Ghostty, Zed, workstation and
personal apps, developer tools, and Xcode. Gaming apps are opt-in. The
[Vim plugin audit](docs/vim-plugin-audit.md) records the migration decisions.

```sh
git clone https://github.com/rahul0705/dotfiles.git
cd dotfiles
git submodule update --init --recursive vendor/etch modules/tmux/files/plugins/tpm modules/ghostty/files/themes/catppuccin modules/oh-my-zsh/files/custom/plugins/zsh-autosuggestions modules/oh-my-zsh/files/custom/plugins/zsh-completions modules/oh-my-zsh/files/custom/plugins/zsh-syntax-highlighting
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
version gate. Bash and Zsh start Starship when it is available.

The fzf module installs through Homebrew on macOS. On Linux, a fresh install
resolves GitHub's latest release and downloads the executable to `~/.local/bin/fzf`.
Existing fzf tools are reused. Presence checks let Etch skip installation entirely
on later applies, without a network check or an executed-script result.
The Linux installer requires curl, tar, and standard filesystem utilities; no Git
checkout, Go build, package-manager, or sudo access is needed. AMD64 and ARM64
release binaries are supported. Downloads are verified before installation, temporary
archives are cleaned up, and conflicting destination paths are not overwritten.
Both shells source one shared integration file for Ctrl-R history search, Ctrl-T
file selection, and Alt-C directory selection. Local after-hooks can override
these bindings. Versions older than 0.48 stay usable as CLI tools but skip the
combined shell integration. Automatic Linux upgrades are outside this module's
scope; Homebrew handles macOS upgrades.

The fonts module installs Hack and FiraCode Nerd Fonts. On Linux it runs Nerd
Fonts' upstream installer for each font in the user font directory and refreshes
the font cache; on macOS it installs the existing Homebrew font casks. Existing
font files or installed casks are skipped on later applies.

The shell-common module deploys portable PATH, Homebrew, Cargo, and NVM setup to
`~/.config/shell/environment.sh`, sourced by Bash and Zsh. Shell-specific prompt
initialization, plugins, completions, and keybindings stay in the respective rc files.

The shared file uses the user configuration directory convention, but neither shell
loads `~/.config/shell` automatically: the managed startup files source it explicitly.
We do not create a custom directory-scanning loader or modify `/etc/profile.d`.

The Bash module deploys `~/.bashrc` and `~/.bash_profile` independently of its framework.
The login profile preserves an existing `~/.profile`, loads the shared environment,
and starts `.bashrc` for interactive login sessions without double-loading it.
Use `~/.bash_profile_before_local` and `~/.bash_profile_after_local` for local login
customizations. Existing regular `.bash_profile` files must be backed up or migrated
before Etch can create its link; Etch will not overwrite them. Oh My Bash
requires Bash and clones the official framework into its default `~/.oh-my-bash`
directory. Upstream's installer lacks a keep-bashrc flag, so cloning avoids replacing
the managed rc file without a restore script or a non-default installation prefix.
The clone retains the upstream installer's non-group/world-writable permissions.
Bash installs `bash-completion@2` through Homebrew on macOS; Homebrew brings in
modern Bash as its dependency. Completion initialization is skipped on Bash below
4.2, so `/bin/bash` on macOS remains usable. To get the extra completions, start the
Homebrew Bash (`bash` after Homebrew's bin directory is on PATH). We do not change
your login shell. Linux users should install their distro's `bash-completion`
package, as our CI prerequisites do.
Bash and Zsh use Starship when available and preserve their local before/after hooks.
Bash-it is no longer managed or loaded; existing `~/.bash-it` data is left intact.

The Zsh module deploys `~/.zprofile` and `~/.zshrc`. Oh My Zsh requires Zsh,
installs noninteractively while preserving the linked rc file, and links the
suggestion, completion, and syntax-highlighting plugins. Powerlevel9k/10k and
Base16 are no longer managed. Existing theme links in the home directory can be
removed manually; Etch does not delete retired configuration or user data.

The VS Code module installs the macOS cask and links settings/keybindings on
macOS, Linux, and Windows. Windows uses the standard
`~/AppData/Roaming/Code/User` location; redirected APPDATA locations require a
corresponding path change. Mac task shortcuts retain Cmd; Windows/Linux use Ctrl.
Extension installation runs through the external provider on macOS/Linux when
`code` is available, with two additional attempts for recognized temporary
Marketplace failures (429/502/503/504). Other errors still fail immediately.
Linux and Windows application installation is user-managed;
Windows extension installation is not yet qualified by the provider.

For initial Windows testing, run from the dotfiles checkout in PowerShell:

```powershell
python -S vendor/etch/etch plan vscode
python -S vendor/etch/etch apply vscode
```

The developer profile skips Unix-only and macOS-only modules on native Windows. File links
require Windows Developer Mode or symbolic-link privileges. Back up/migrate
existing regular settings/keybindings files before applying; Etch will not replace
them automatically. The POSIX `./etch` launcher is not used for native Windows.
To apply the Windows-compatible parts of the developer profile:

```powershell
python -S vendor/etch/etch apply --profile developer
```

This configures Git, Codex guidance/plugins (when native Codex is installed),
VS Code files, Starship configuration, and the user-local Etch launcher. It does
not install those applications or the macOS-only MCP tools.

On macOS and Linux, the Vim module links `~/.vim` and `~/.vimrc`, uses Etch's managed `download`
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

## Finder preferences

The macOS-only `finder` module manages filename extensions, path/status bars,
hidden-file visibility, and Finder metadata on network/removable volumes using
Etch's native preferences plugin. It is included in the developer profile.
See [Finder preferences](docs/finder-preferences.md) for inspected values,
desired defaults, application commands, and manual Finder refresh instructions.

## Codex configuration

The `codex` module links global working preferences to `~/.codex/AGENTS.md`
and a portable named profile to `~/.codex/dotfiles.config.toml`. It is included
in the developer profile and can also be applied with `./etch apply homebrew codex`.
Codex installation is user-managed. Global guidance applies to new Codex sessions;
select the optional macOS settings with `codex --profile dotfiles`.

Existing regular files are not overwritten. Before the first apply, review and
back up a conflicting `~/.codex/AGENTS.md` or `dotfiles.config.toml`, then move
it out of the destination. Retain any personal guidance you still need.
An existing `AGENTS.override.md` takes precedence over the managed guidance.

The module registers native Codex marketplaces and installs these plugins on
macOS, Linux, and Windows when the user-managed `codex` CLI is on PATH
(0.154.0 or newer). On Windows, expose the native `codex.exe`; the provider
does not execute `codex.cmd` or `codex.bat` wrappers:

| Marketplace source | Native plugin selector |
| --- | --- |
| `DietrichGebert/ponytail` | `ponytail@ponytail` |
| `JuliusBrussee/caveman` | `caveman@caveman` |
| `mattpocock/skills` | `mattpocock-skills@mattpocock` |

Etch uses Codex's native user plugin storage, honoring `CODEX_HOME` when set.
It preserves installed versions, disabled plugins, and unrelated installations.
It does not install Codex, enable existing disabled plugins, or upgrade plugins.
No Claude Code installation or subscription is required. Matt Pocock's bundle
includes `to-spec`, `to-tickets`, and `handoff`, alongside its other skills.
Those workflows can write issues or files when invoked; installation does not
run them or grant permission to publish anything.

For an existing setup, first apply and verify native inventory:

```sh
./etch apply homebrew codex
codex plugin marketplace list --json
codex plugin list --json
```

Enable Ponytail and Caveman in Codex's plugin settings if previously disabled.
After confirming native skills are available, remove only the old dotfiles-owned
symlinks `~/.agents/skills/ponytail` and `~/.agents/skills/caveman`; do not delete
unrelated skills or regular directories at those paths. These links are no longer
created by Etch. The upstream skill submodules have been retired.

Restart or refresh the Codex app and start a new session to reload plugins.
The CLI and Codex desktop use the same user storage; a CLI installation alone
does not prove that a running desktop or ChatGPT session has loaded it.
Check that the relevant skills appear in that app before relying on them.
Global guidance applies Ponytail by default to coding tasks when available;
Caveman remains opt-in. Ponytail also ships native lifecycle hooks; Caveman's
currently installed package exposes skills without Codex hooks.

Manage additional plugins through native commands:

```sh
codex plugin marketplace add OWNER/REPO --json
codex plugin add PLUGIN@MARKETPLACE --json
codex plugin marketplace upgrade MARKETPLACE --json
```

`marketplace upgrade` refreshes the catalog; it does not promise to update an
installed plugin. Use Codex's plugin settings to review available updates.
Dependabot continues updating Git submodules such as Etch; native skill packages
are managed by Codex rather than Dependabot. Their licenses remain upstream.

The guidance file is deployed on macOS, Linux, and Windows. The named profile,
uv, RTK, Serena, and Codebase Memory remain macOS-only. On Linux and Windows,
this module installs native Codex plugins but does not install the CLI or MCP
tools. On macOS, uv comes from Homebrew, matching
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
use the current package releases. Restart agent sessions after upgrading MCP tools.

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

## User-local tool PATH

The managed Bash and Zsh rc files add `~/.local/bin` to PATH without duplicates.
This exposes uv-installed tools such as Serena and Codebase Memory, and any
future tools installed there. Open a new interactive shell after applying the
shell module, or source `~/.bashrc` / `~/.zshrc` in the matching shell. Restart
apps separately if they inherited an older PATH; desktop app PATH inheritance
is not controlled by shell rc files. Existing before/after local customizations
remain available.

Deploying either Bash or Zsh also applies the `etch` module, which links the
repository-owned launcher to `~/.local/bin/etch`. This is a user-local command;
no system directory or entire checkout is added to PATH. The launcher follows
symlinks to select this checkout even when invoked from another directory.
Existing regular-file conflicts are refused rather than overwritten.

```sh
./etch plan etch
./etch apply etch
# In a new managed shell, from any directory:
etch validate
```

On native Windows, the `etch` module links the repository's `etch.cmd` launcher
into `~/.local/bin` and adds that directory to the **user** PATH once during
setup. Existing user PATH entries and their Registry value type are preserved; the machine PATH is untouched. Open a new terminal after the
first apply, then run `etch validate` from any directory. Python must remain on
PATH, and Windows Developer Mode or symlink privileges are required for links.
The launcher resolves its symlink back to this checkout and forwards arguments;
with no arguments it previews the developer profile. No shell profile is edited.
The setup marker is `~/.local/state/etch/windows-user-path`; remove it and rerun
the module if you later remove the directory from user PATH and want to restore it.

A bare `etch` still previews the developer profile. The Unix launcher uses POSIX
shell and ordinary `readlink`, including relative symlink targets; it refuses
dangling links and chains exceeding 40 links. This adopts the engine capability
and launcher behavior tracked in [Etch #149](https://github.com/rm-industries/etch/issues/149).
Other template consumers can opt into user-local exposure independently of any
shell deployment; this repository supplies its own Bash/Zsh PATH configuration.
