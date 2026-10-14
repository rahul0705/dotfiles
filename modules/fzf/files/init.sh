# Shared interactive integration; tool installation never edits our shell startup files.
# Local after-hooks can override fzf's Ctrl-R, Ctrl-T, and Alt-C bindings.
case $- in
    *i*) ;;
    *) return ;;
esac

if command -v fzf >/dev/null 2>&1; then
    if [ -n "${ZSH_VERSION:-}" ]; then
        _fzf_shell=zsh
    elif [ -n "${BASH_VERSION:-}" ]; then
        _fzf_shell=bash
    else
        return
    fi
    # Combined integration requires fzf 0.48+; leave older existing tools usable.
    if _fzf_setup=$(fzf "--$_fzf_shell" 2>/dev/null); then
        eval "$_fzf_setup"
    fi
    unset _fzf_setup _fzf_shell
fi
