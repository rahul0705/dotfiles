#!/bin/sh
# Fresh-machine bootstrap; existing checkouts are deliberately never updated.
set -u

repository=https://github.com/rahul0705/dotfiles.git
destination=${DOTFILES_DIR:-"$HOME/.dotfiles"}
module=etch
no_module=false

die() {
    printf 'Dotfiles installer: %s\n' "$2" >&2
    exit "$1"
}

while [ "$#" -gt 0 ]; do
    case "$1" in
        --module)
            [ "$#" -ge 2 ] || die 2 '--module requires a name.'
            module=$2
            case "$module" in
                ''|-*|*[!a-zA-Z0-9_-]*) die 2 'Invalid module name.' ;;
            esac
            shift 2
            ;;
        --no-module) no_module=true; shift ;;
        --help|-h)
            printf '%s\n' 'Usage: install.sh [--module NAME] [--no-module]' \
                'Clone to DOTFILES_DIR (default: ~/.dotfiles), then apply only etch.' \
                '--no-module always takes precedence. Existing checkouts are untouched.'
            exit 0
            ;;
        *) die 2 "Unknown argument: $1" ;;
    esac
done
[ "$no_module" = false ] || module=
command -v git >/dev/null 2>&1 || die 127 'Git is required; install it and retry.'

if [ -e "$destination" ] || [ -L "$destination" ]; then
    if [ -d "$destination" ] && [ -e "$destination/.git" ]; then
        origin=$(git -C "$destination" remote get-url origin 2>/dev/null) || origin=
        case "$origin" in
            https://github.com/rahul0705/dotfiles|https://github.com/rahul0705/dotfiles.git|git@github.com:rahul0705/dotfiles|git@github.com:rahul0705/dotfiles.git)
                git -C "$destination" rev-parse --is-inside-work-tree >/dev/null 2>&1 ||
                    die 1 "Invalid checkout at $destination; it was not changed."
                printf 'Dotfiles already exist at %s; nothing changed.\n' "$destination"
                exit 0
                ;;
        esac
    fi
    die 1 "Destination is occupied by an unrelated file or directory: $destination"
fi

if [ -n "$module" ]; then
    command -v python3 >/dev/null 2>&1 || die 127 'Python 3.9+ is required to run Etch; install it or use --no-module.'
    python3 -S -c 'import sys; sys.exit(sys.version_info < (3, 9))' ||
        die "$?" 'Python 3.9+ is required to run Etch.'
fi

GIT_TERMINAL_PROMPT=0 git clone -- "$repository" "$destination" ||
    die "$?" "Clone failed. Any partial destination was retained at $destination; inspect it before retrying."
GIT_TERMINAL_PROMPT=0 git -C "$destination" submodule update --init --recursive ||
    die "$?" "Submodule initialization failed at $destination. Repair it manually; reruns do not update existing checkouts."

if [ -n "$module" ]; then
    python3 -S "$destination/vendor/etch/etch" apply "$module" --repo "$destination" ||
        die "$?" "Etch module $module failed. Checkout retained at $destination; rerun Etch directly after resolving the error."
fi
printf 'Dotfiles installed at %s.\n' "$destination"
