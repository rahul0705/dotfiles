#!/usr/bin/env bash
set -euo pipefail

# Bootstrap Python before replacing HOME with an isolated Etch home.
work_dir=$(mktemp -d)
trap 'rm -rf "$work_dir"' EXIT
curl -fsSL https://astral.sh/uv/0.13.0/install.sh -o "$work_dir/install-uv.sh"
UV_UNMANAGED_INSTALL="$work_dir/uv" sh "$work_dir/install-uv.sh"
export UV_PYTHON_INSTALL_DIR="$work_dir/python"
"$work_dir/uv/uv" python install "$PYTHON_VERSION"
mkdir -p "$work_dir/bin"
ln -s "$("$work_dir/uv/uv" python find --managed-python "$PYTHON_VERSION")" "$work_dir/bin/python3"
export PATH="$work_dir/bin:$PATH"
python3 --version

git submodule update --init --recursive vendor/etch modules
export HOME="$work_dir/etch-home"
mkdir -p "$HOME"
if [[ "$(uname -s)" == Darwin ]]; then
    export HOMEBREW_CASK_OPTS="--appdir=$work_dir/etch-apps"
    mkdir -p "$work_dir/etch-apps"
fi
./etch validate
./etch plan --profile developer
if [[ "$(uname -s)" == Darwin ]] && ! command -v brew >/dev/null; then
    ./etch apply --profile developer --allow-sudo
    case "$(uname -m)" in
        arm64) brew_bin=/opt/homebrew/bin/brew ;;
        *) brew_bin=/usr/local/bin/brew ;;
    esac
    eval "$("$brew_bin" shellenv)"
fi
./etch apply --profile developer
