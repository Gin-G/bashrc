# Kubernetes, Helm, ArgoCD aliases and helpers.

# --- kubectl aliases --------------------------------------------------------
alias k='kubectl'
alias kg='kubectl get'
alias kgp='kubectl get pods'
alias kgpw='kubectl get pods -o wide'
alias kgpa='kubectl get pods -A'
alias kgs='kubectl get svc'
alias kgi='kubectl get ingress'
alias kgn='kubectl get nodes'
alias kgd='kubectl get deploy'
alias kgss='kubectl get statefulsets'
alias kgds='kubectl get daemonsets'
alias kgcm='kubectl get configmaps'
alias kgsec='kubectl get secrets'
alias kgpv='kubectl get pv'
alias kgpvc='kubectl get pvc'
alias kgns='kubectl get namespaces'
alias kgall='kubectl get all'
alias kge='kubectl get events --sort-by=.lastTimestamp'

alias kd='kubectl describe'
alias kdp='kubectl describe pod'
alias kds='kubectl describe svc'
alias kdn='kubectl describe node'

alias kl='kubectl logs'
alias klf='kubectl logs -f'
alias klp='kubectl logs -p'

alias ke='kubectl exec -it'
alias kaf='kubectl apply -f'
alias kdf='kubectl delete -f'
alias kdel='kubectl delete'
alias kpf='kubectl port-forward'
alias kcp='kubectl cp'
alias kexp='kubectl explain'
alias kapi='kubectl api-resources'

# Workloads / jobs
alias kgj='kubectl get jobs'
alias kgcj='kubectl get cronjobs'

# Resource usage (requires metrics-server)
alias ktop='kubectl top'
alias ktopp='kubectl top pods'
alias ktopn='kubectl top nodes'

# Rollouts
alias kr='kubectl rollout'
alias krs='kubectl rollout status'
alias krr='kubectl rollout restart'
alias krh='kubectl rollout history'
alias kru='kubectl rollout undo'

alias kctx='kubectl config current-context'
alias kctxs='kubectl config get-contexts'
alias kuse='kubectl config use-context'
alias kns='kubectl config set-context --current --namespace'

# kubectl completion + bind to `k`
if command -v kubectl >/dev/null 2>&1; then
    # kubectl is slow to start (large binary, often on NFS), so cache the
    # completion script and only regenerate it when the binary changes.
    __df_kcomp="${XDG_CACHE_HOME:-$HOME/.cache}/dotfiles/kubectl-completion.bash"
    __df_kbin="$(command -v kubectl)"
    if [ ! -s "$__df_kcomp" ] || [ "$__df_kbin" -nt "$__df_kcomp" ]; then
        mkdir -p "${__df_kcomp%/*}"
        kubectl completion bash >"$__df_kcomp" 2>/dev/null || rm -f "$__df_kcomp"
    fi
    # shellcheck disable=SC1090
    [ -s "$__df_kcomp" ] && source "$__df_kcomp"
    unset __df_kcomp __df_kbin
    if declare -F __start_kubectl >/dev/null 2>&1; then
        complete -F __start_kubectl k
    fi
fi

# --- kubectl helper functions ----------------------------------------------

# Switch namespace: positional arg, else fzf.
ksns() {
    local ns="$1"
    if [ -z "$ns" ]; then
        command -v fzf >/dev/null 2>&1 || { echo "ksns: pass a namespace or install fzf" >&2; return 2; }
        ns="$(kubectl get ns -o name | sed 's@^namespace/@@' | fzf --height=40% --reverse)"
    fi
    [ -n "$ns" ] || return 1
    kubectl config set-context --current --namespace "$ns"
}

# Switch context: positional arg, else fzf.
kctxsw() {
    local ctx="$1"
    if [ -z "$ctx" ]; then
        command -v fzf >/dev/null 2>&1 || { echo "kctxsw: pass a context or install fzf" >&2; return 2; }
        ctx="$(kubectl config get-contexts -o name | fzf --height=40% --reverse)"
    fi
    [ -n "$ctx" ] || return 1
    kubectl config use-context "$ctx"
}

# Exec into the first pod whose name matches a pattern. Defaults to bash, falls back to sh.
kshell() {
    [ -n "$1" ] || { echo "usage: kshell <pattern> [shell]" >&2; return 2; }
    local pattern="$1"
    local shell="${2:-bash}"
    local pod
    pod="$(kubectl get pods --no-headers -o custom-columns=:metadata.name | grep -m1 -- "$pattern")"
    [ -n "$pod" ] || { echo "kshell: no pod matched '$pattern'" >&2; return 1; }
    if [ "$shell" = "bash" ]; then
        kubectl exec -it "$pod" -- bash 2>/dev/null || kubectl exec -it "$pod" -- sh
    else
        kubectl exec -it "$pod" -- "$shell"
    fi
}

# Follow logs of the first pod matching a pattern.
ktail() {
    [ -n "$1" ] || { echo "usage: ktail <pattern>" >&2; return 2; }
    local pod
    pod="$(kubectl get pods --no-headers -o custom-columns=:metadata.name | grep -m1 -- "$1")"
    [ -n "$pod" ] || { echo "ktail: no pod matched '$1'" >&2; return 1; }
    kubectl logs -f "$pod"
}

# --- Helm -------------------------------------------------------------------
alias hl='helm list'
alias hi='helm install'
alias hu='helm uninstall'
alias huf='helm upgrade --install'
alias hd='helm diff'
alias hist='helm history'

# --- ArgoCD -----------------------------------------------------------------
alias acd='argocd'
alias acdapp='argocd app'
alias acdsync='argocd app sync'
alias acdget='argocd app get'

# --- k9s / kubectl-neat -----------------------------------------------------
alias k9='k9s'
alias kcat='kubectl neat'
