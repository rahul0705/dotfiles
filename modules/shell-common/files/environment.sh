# Shared, portable environment for Bash and Zsh. Keep shell-specific syntax in their rc files.
# uv tool executables and the Etch launcher belong in the user-local bin directory.
case ":${PATH}:" in
    *":$HOME/.local/bin:"*) ;;
    *) export PATH="$HOME/.local/bin:$PATH" ;;
esac

# Initialize Homebrew once, including when it is not yet on PATH on a fresh Mac.
if [ -z "${HOMEBREW_PREFIX:-}" ]; then
    for _shell_brew in /opt/homebrew/bin/brew /usr/local/bin/brew; do
        if [ -x "$_shell_brew" ]; then
            eval "$("$_shell_brew" shellenv)"
            break
        fi
    done
    unset _shell_brew
fi

if [ -f "$HOME/.cargo/env" ]; then
    . "$HOME/.cargo/env"
fi

# NVM is interactive tooling; use the same installation in both shells.
case $- in
    *i*)
        export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
        if ! command -v nvm >/dev/null 2>&1; then
            if [ -s "$NVM_DIR/nvm.sh" ]; then
                . "$NVM_DIR/nvm.sh"
            elif [ -n "${HOMEBREW_PREFIX:-}" ] && [ -s "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" ]; then
                . "$HOMEBREW_PREFIX/opt/nvm/nvm.sh"
            fi
        fi
        ;;
esac
