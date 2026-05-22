# General-purpose shell functions.

# mkdir + cd
mkcd() {
    [ -n "$1" ] || { echo "usage: mkcd <dir>" >&2; return 2; }
    mkdir -p -- "$1" && cd -- "$1"
}

# Extract most common archive formats
extract() {
    [ -f "$1" ] || { echo "extract: '$1' is not a file" >&2; return 2; }
    case "$1" in
        *.tar.bz2|*.tbz2) tar xvjf "$1" ;;
        *.tar.gz|*.tgz)   tar xvzf "$1" ;;
        *.tar.xz|*.txz)   tar xvJf "$1" ;;
        *.tar)            tar xvf  "$1" ;;
        *.bz2)            bunzip2  "$1" ;;
        *.gz)             gunzip   "$1" ;;
        *.zip)            unzip    "$1" ;;
        *.7z)             7z x     "$1" ;;
        *.rar)            unrar x  "$1" ;;
        *) echo "extract: unsupported format: $1" >&2; return 1 ;;
    esac
}

# Find file / directory by name (case-insensitive, anywhere under .)
ff() {
    [ -n "$1" ] || { echo "usage: ff <pattern>" >&2; return 2; }
    find . -type f -iname "*$1*" 2>/dev/null
}

fd() {
    [ -n "$1" ] || { echo "usage: fd <pattern>" >&2; return 2; }
    find . -type d -iname "*$1*" 2>/dev/null
}

# cd up N levels: `up 3` == `cd ../../..`
up() {
    local n="${1:-1}"
    case "$n" in ''|*[!0-9]*) echo "usage: up <N>" >&2; return 2 ;; esac
    local p=""
    local i
    for ((i=0; i<n; i++)); do p="../$p"; done
    cd "$p" || return
}

# Show HTTP status + timing for a URL
httpstat() {
    [ -n "$1" ] || { echo "usage: httpstat <url>" >&2; return 2; }
    curl -o /dev/null -sS -w \
'http_code:   %{http_code}\nnamelookup:  %{time_namelookup}s\nconnect:     %{time_connect}s\nappconnect:  %{time_appconnect}s\nstarttx:     %{time_starttransfer}s\ntotal:       %{time_total}s\nsize_dl:     %{size_download} bytes\n' \
"$1"
}

# Colored diff (prefers colordiff, falls back to diff -u)
cdiff() {
    if command -v colordiff >/dev/null 2>&1; then
        colordiff -u "$@"
    else
        diff -u "$@"
    fi
}

# Print the N biggest files under the current directory
biggest() {
    local n="${1:-20}"
    find . -type f -printf '%s\t%p\n' 2>/dev/null \
        | sort -rn \
        | head -n "$n" \
        | numfmt --field=1 --to=iec --suffix=B --padding=10
}

# Delete local branches that have been merged into the default branch on origin
git-prune-merged() {
    local default
    default="$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null | sed 's@^origin/@@')"
    default="${default:-main}"
    git fetch --all --prune
    git branch --merged "origin/$default" \
        | grep -vE "^[* ]+($default|master)\$" \
        | xargs -r -n1 git branch -d
}
