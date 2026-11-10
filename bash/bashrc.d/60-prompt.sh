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

# kubectl is slow to start (large binary, often on NFS), so cache the kube
# segment in __df_kube_seg and only rerun __df_kube when $KUBECONFIG or the
# files it names change. Runs from PROMPT_COMMAND rather than a PS1 $(...)
# subshell so the cache survives between prompts, and is also saved to a file
# so new shells can reuse it.
__df_kube_update() {
    local key f cache
    key="${DOTFILES_PROMPT_KUBE:-1}|${KUBECONFIG:-$HOME/.kube/config}"
    local IFS=:
    for f in ${KUBECONFIG:-$HOME/.kube/config}; do
        key+="|$(stat -c '%y %s' -- "$f" 2>/dev/null)"
    done
    [ "$key" = "${__df_kube_key-}" ] && return 0
    __df_kube_key=$key
    cache="${XDG_CACHE_HOME:-$HOME/.cache}/dotfiles/kube-prompt"
    if [ -r "$cache" ] && { IFS= read -r f && [ "$f" = "$key" ] && IFS= read -r __df_kube_seg; } <"$cache"; then
        return 0
    fi
    __df_kube_seg="$(__df_kube)"
    mkdir -p "${cache%/*}" 2>/dev/null &&
        printf '%s\n%s\n' "$key" "$__df_kube_seg" >"$cache" 2>/dev/null
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
PS1+="${__df_c_magenta}\${__df_kube_seg}${__df_c_reset}"
PS1+="\n\$ "
export PS1

# xterm-family window title.
case "$TERM" in
    xterm*|rxvt*|tmux*|screen*)
        PROMPT_COMMAND='printf "\033]0;%s@%s:%s\007" "$USER" "${HOSTNAME%%.*}" "${PWD/#$HOME/~}"'
        export PROMPT_COMMAND
        ;;
esac
case "${PROMPT_COMMAND-}" in
    *__df_kube_update*) ;;
    *) PROMPT_COMMAND="__df_kube_update${PROMPT_COMMAND:+; $PROMPT_COMMAND}" ;;
esac
