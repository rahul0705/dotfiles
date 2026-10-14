#!/bin/sh
set -eu
# Release archives include the version in their name; update this when upgrading fzf.
version=0.74.5
case "$(uname -m)" in
    x86_64) arch=amd64 ;;
    aarch64|arm64) arch=arm64 ;;
    *) printf 'No configured fzf binary for this architecture\n' >&2; exit 1 ;;
esac
if [ -e "$HOME/.local/bin/fzf" ] || [ -L "$HOME/.local/bin/fzf" ]; then
    printf 'Refusing to replace conflicting ~/.local/bin/fzf\n' >&2
    exit 1
fi
work_dir=$(mktemp -d)
trap 'rm -rf "$work_dir"' EXIT
curl -fsSL "https://github.com/junegunn/fzf/releases/download/v$version/fzf-$version-linux_$arch.tar.gz" -o "$work_dir/fzf.tar.gz"
tar -xzf "$work_dir/fzf.tar.gz" -C "$work_dir" fzf
mkdir -p "$HOME/.local/bin"
install -m 755 "$work_dir/fzf" "$HOME/.local/bin/fzf"
