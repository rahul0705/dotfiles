# Dotfiles

## Etch migration (issue #81)

The migration is being reviewed in small PRs targeting `dev`. The first slice
contains the Git module only; `developer` is an incremental Etch profile, not a
replacement for the existing macOS/Linux Dotbot profiles yet.

```sh
git clone --branch dev https://github.com/rahul0705/dotfiles.git
cd dotfiles
git submodule update --init vendor/etch
./etch                              # preview only
./etch plan --profile developer -v
./etch doctor --profile developer
./etch apply --profile developer
./etch apply --profile developer     # established links should be skipped
```

These commands are available after the migration PR lands on `dev`; before then,
check out its feature branch. Python 3.9+ and Git are required. The launcher uses
the pinned Etch source with site packages disabled; no global Etch or Python
package installation is needed. Homebrew and VS Code reference plugins are
explicitly registered from that same pin, but this slice invokes neither tool.

The Git module owns `.gitconfig`, `.gitignore_global`, and `.gitmessage`.
`tools/vcs/git` remains a compatibility link, so existing home links and Dotbot's
`install-profile` / `install-standalone git` continue to use the same files.
Etch creates missing parent directories and may replace different symlinks,
matching the old link defaults. It refuses to overwrite regular files or
directories: review and back up those conflicts before applying. Broad Dotbot
cleanup is not migrated; Etch must have ownership receipts before removing links.
Machine-local receipts live in the ignored `.etch/` directory.

To try this slice without changing your home:

```sh
test_home=$(mktemp -d)
HOME="$test_home" ./etch plan --profile developer
HOME="$test_home" ./etch apply --profile developer
HOME="$test_home" ./etch apply --profile developer
python3 -S -m unittest discover -s tests -v
```

This slice was checked on macOS 27.0, arm64, with Python 3.14.7 in temporary
homes: read-only preview, first apply, unchanged second apply, regular-file
conflict preservation, and the original Dotbot Git installation. The workflow
also runs the Etch checks on Linux/macOS with Python 3.9 and 3.14; those results
must be checked in CI before claiming that matrix is verified. This is Git-only
evidence, not a full developer-profile installation.

Subsequent review slices will cover tmux version selection, Starship installation
and fact refresh, then the remaining modules, platform profiles and real platform
evidence. Issue #81 stays open until those acceptance criteria are verified.

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
