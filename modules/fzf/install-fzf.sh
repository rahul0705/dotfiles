#!/bin/sh
set -eu

destination="$HOME/.local/bin/fzf"
# Install only when absent; preserve existing tools even when invoked outside Etch.
if command -v fzf >/dev/null 2>&1; then
    exit 0
fi
if [ -e "$destination" ] || [ -L "$destination" ]; then
    if [ ! -L "$destination" ] && [ -f "$destination" ] && [ -x "$destination" ]; then
        exit 0
    fi
    printf 'Refusing to replace conflicting ~/.local/bin/fzf\n' >&2
    exit 1
fi

case "$(uname -m)" in
    x86_64) arch=amd64 ;;
    aarch64|arm64) arch=arm64 ;;
    *) printf 'No configured fzf binary for this architecture\n' >&2; exit 1 ;;
esac

# GitHub's documented latest-release redirect avoids API credentials/rate limits.
release_url=$(curl -fsSIL --connect-timeout 10 --max-time 30 --output /dev/null \
    --write-out '%{url_effective}' https://github.com/junegunn/fzf/releases/latest)
tag=${release_url##*/}
version=${tag#v}
if ! printf '%s\n' "$version" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+$'; then
    printf 'Could not resolve the latest fzf release\n' >&2
    exit 1
fi
# Verify in a temporary directory before placing the binary at its final path.
mkdir -p "$HOME/.local/bin"
work_dir=$(mktemp -d "$HOME/.local/bin/.fzf-install.XXXXXX")
trap 'rm -rf "$work_dir"' EXIT
trap 'exit 1' HUP INT TERM
curl -fsSL --connect-timeout 10 --max-time 120 \
    "https://github.com/junegunn/fzf/releases/download/$tag/fzf-$version-linux_$arch.tar.gz" \
    --output "$work_dir/fzf.tar.gz"
tar -xzf "$work_dir/fzf.tar.gz" -C "$work_dir" fzf
chmod 755 "$work_dir/fzf"
downloaded=$(FZF_DEFAULT_OPTS= "$work_dir/fzf" --version)
if [ "${downloaded%% *}" != "$version" ]; then
    printf 'Downloaded fzf version does not match the release\n' >&2
    exit 1
fi
mv -f "$work_dir/fzf" "$destination"
printf 'Installed fzf %s\n' "$version"
