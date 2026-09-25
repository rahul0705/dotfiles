#!/bin/sh
set -eu

mkdir -p "$HOME/.local/bin"
BIN_DIR="$HOME/.local/bin" exec /bin/sh "$@"
