# Dotfiles

## Etch migration (issue #81)

The migration is being reviewed in small PRs targeting `dev`. The incremental
Etch `developer` profile currently covers Git and tmux; it does not yet replace
the existing macOS/Linux Dotbot profiles.

```sh
git clone --branch dev https://github.com/rahul0705/dotfiles.git
cd dotfiles
git submodule update --init --recursive vendor/etch modules/tmux/files/plugins/tpm
./etch                              # preview only
./etch plan --profile developer -v
./etch doctor --profile developer
./etch apply --profile developer
./etch apply --profile developer     # established links should be skipped
```

The tmux module is available after its PR lands on `dev`; before then, check
out its feature branch. Python 3.9+, Git, and tmux are required. The launcher
uses the pinned Etch source with site packages disabled; no global Etch or
Python package installation is needed. Homebrew and VS Code reference plugins
are explicitly registered from that same pin, but these modules invoke neither.

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

To try this slice without changing your home:

```sh
test_home=$(mktemp -d)
HOME="$test_home" ./etch plan --profile developer
HOME="$test_home" ./etch apply --profile developer
HOME="$test_home" ./etch apply --profile developer
```

The Git slice passed on macOS 27.0, arm64, with Python 3.14.7 in temporary
homes, and its CI checks passed on Linux and macOS with Python 3.9 and 3.14.
The expanded CI runs Etch with Git and tmux on those runners, inspects the
installed links and selected modern config, and confirms the second apply
makes no changes. It simulates tmux 2.0 to inspect the legacy selection; it
does not run an old tmux binary or install third-party TPM plugins.

Subsequent review slices will cover Starship installation and fact refresh,
then the remaining modules, platform profiles and real platform evidence.
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
