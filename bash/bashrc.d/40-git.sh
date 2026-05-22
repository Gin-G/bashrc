# Git aliases and helpers.

alias g='git'
alias gs='git status -sb'
alias gss='git status'
alias gd='git diff'
alias gds='git diff --staged'
alias ga='git add'
alias gaa='git add -A'
alias gap='git add -p'
alias gc='git commit'
alias gcm='git commit -m'
alias gca='git commit --amend'
alias gcan='git commit --amend --no-edit'
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gpl='git pull'
alias gplr='git pull --rebase'
alias gf='git fetch --all --prune'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gsw='git switch'
alias gswc='git switch -c'
alias gb='git branch'
alias gbd='git branch -d'
alias gbD='git branch -D'
alias gl='git log --oneline --graph --decorate -20'
alias gla='git log --oneline --graph --decorate --all -20'
alias glp='git log -p'
alias gsta='git stash'
alias gstp='git stash pop'
alias gstl='git stash list'
alias gr='git reset'
alias grb='git rebase'
alias grbi='git rebase -i'
alias grbc='git rebase --continue'
alias grba='git rebase --abort'
alias gcp='git cherry-pick'
alias gclean='git clean -fd'
alias gundo='git reset --soft HEAD~1'

# Show stat + name-status for HEAD or a given ref.
glast() {
    local ref="${1:-HEAD}"
    git show --stat --name-status "$ref"
}

# Stage everything, commit with message.
gcam() {
    [ -n "$1" ] || { echo "usage: gcam <message>" >&2; return 2; }
    git add -A && git commit -m "$*"
}
