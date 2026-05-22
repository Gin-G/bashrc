# PS1: user@host, cwd, git branch, kube context/namespace.

# Color shortcuts (wrapped in \[ \] so readline counts them as zero-width).
__df_c_reset='\[\e[0m\]'
__df_c_green='\[\e[1;32m\]'
__df_c_blue='\[\e[1;34m\]'
__df_c_yellow='\[\e[1;33m\]'
__df_c_magenta='\[\e[1;35m\]'

# Current git branch, or short rev if detached. Prints " (branch)".
__df_git_branch() {
    local b
    b="$(git symbolic-ref --quiet --short HEAD 2>/dev/null)"
    if [ -z "$b" ]; then
        b="$(git rev-parse --short HEAD 2>/dev/null)" || return 0
    fi
    [ -n "$b" ] && printf ' (%s)' "$b"
}

# Current kube context:namespace. Gated by DOTFILES_PROMPT_KUBE (default 1).
__df_kube() {
    [ "${DOTFILES_PROMPT_KUBE:-1}" = "1" ] || return 0
    command -v kubectl >/dev/null 2>&1 || return 0
    local ctx ns
    ctx="$(kubectl config current-context 2>/dev/null)" || return 0
    [ -n "$ctx" ] || return 0
    ns="$(kubectl config view --minify -o jsonpath='{..namespace}' 2>/dev/null)"
    [ -n "$ns" ] || ns='default'
    printf ' [\xe2\x8e\x88 %s:%s]' "$ctx" "$ns"
}

# Only set PS1 on interactive, non-dumb terminals.
case "$-" in *i*) ;; *) return 0 ;; esac
[ "$TERM" = "dumb" ] && return 0

# Debian chroot indicator (used by /etc/skel/.bashrc convention).
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

PS1='${debian_chroot:+($debian_chroot)}'
PS1+="${__df_c_green}\u@\h${__df_c_reset}:${__df_c_blue}\w${__df_c_reset}"
PS1+="${__df_c_yellow}\$(__df_git_branch)${__df_c_reset}"
PS1+="${__df_c_magenta}\$(__df_kube)${__df_c_reset}"
PS1+="\n\$ "
export PS1

# xterm-family window title.
case "$TERM" in
    xterm*|rxvt*|tmux*|screen*)
        PROMPT_COMMAND='printf "\033]0;%s@%s:%s\007" "$USER" "${HOSTNAME%%.*}" "${PWD/#$HOME/~}"'
        export PROMPT_COMMAND
        ;;
esac
