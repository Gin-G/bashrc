# PATH, environment, history, locale, man-page colors.

# Prepend a directory to PATH if it exists and isn't already there.
path_prepend() {
    local d="$1"
    [ -d "$d" ] || return 0
    case ":$PATH:" in
        *":$d:"*) ;;
        *) PATH="$d${PATH:+:$PATH}" ;;
    esac
}

path_prepend "/usr/local/go/bin"
path_prepend "$HOME/.cargo/bin"
path_prepend "${KREW_ROOT:-$HOME/.krew}/bin"
path_prepend "$HOME/bin"
path_prepend "$HOME/.local/bin"
export PATH

# Editor / pager
export EDITOR=vim
export VISUAL="$EDITOR"
export PAGER=less
export LESS='-R -F -X'

# History
export HISTSIZE=50000
export HISTFILESIZE=100000
export HISTTIMEFORMAT='%F %T '
export HISTCONTROL=ignoreboth:erasedups
export HISTIGNORE='ls:ll:la:cd:pwd:exit:clear:history:h'
shopt -s histappend 2>/dev/null || true
shopt -s checkwinsize 2>/dev/null || true

# Locale defaults (only if not already set, and only if actually installed —
# forcing an uninstalled locale makes bash print setlocale warnings).
if [ -z "$LANG" ] && [ -z "$LC_ALL" ]; then
    if locale -a 2>/dev/null | grep -qi '^en_US\.utf8$'; then
        export LANG="en_US.UTF-8"
    fi
fi

# Colored man pages via less termcap
export LESS_TERMCAP_mb=$'\E[1;31m'
export LESS_TERMCAP_md=$'\E[1;36m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[1;32m'

# lesspipe: let `less` handle archives, PDFs, etc.
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# System-wide bash completion (skip under POSIX mode).
if ! shopt -oq posix; then
    if [ -r /usr/share/bash-completion/bash_completion ]; then
        # shellcheck disable=SC1091
        . /usr/share/bash-completion/bash_completion
    elif [ -r /etc/bash_completion ]; then
        # shellcheck disable=SC1091
        . /etc/bash_completion
    fi
fi
