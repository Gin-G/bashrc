# Python, Conda/Mamba, Homebrew, Docker/Podman, Terraform/OpenTofu.

# --- Python -----------------------------------------------------------------
alias py='python'
alias py3='python3'
alias ipy='ipython'
alias pip-up='pip list --outdated'

# Create .venv in cwd, activate, upgrade pip.
venv() {
    python3 -m venv .venv || return
    # shellcheck disable=SC1091
    . .venv/bin/activate
    pip install --upgrade pip
}

# Activate .venv (or venv) in cwd.
activate() {
    if [ -f .venv/bin/activate ]; then
        # shellcheck disable=SC1091
        . .venv/bin/activate
    elif [ -f venv/bin/activate ]; then
        # shellcheck disable=SC1091
        . venv/bin/activate
    else
        echo "activate: no .venv/ or venv/ in $(pwd)" >&2
        return 1
    fi
}

alias jl='jupyter lab'
alias jn='jupyter notebook'

# --- Conda / Mamba ----------------------------------------------------------
# Guard against double-init when re-sourcing.
if [ -z "${CONDA_SHLVL:-}" ]; then
    if [ -r "$HOME/miniforge3/etc/profile.d/conda.sh" ]; then
        # shellcheck disable=SC1091
        . "$HOME/miniforge3/etc/profile.d/conda.sh"
    fi
    if [ -r "$HOME/miniforge3/etc/profile.d/mamba.sh" ]; then
        # shellcheck disable=SC1091
        . "$HOME/miniforge3/etc/profile.d/mamba.sh"
    fi
fi

alias ca='conda activate'
alias cda='conda deactivate'
alias cenv='conda env list'

# --- Homebrew (Linux) -------------------------------------------------------
if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# --- Docker -----------------------------------------------------------------
alias d='docker'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias dex='docker exec -it'
alias dlogs='docker logs -f'
alias dprune='docker system prune -af'

# --- Podman -----------------------------------------------------------------
if command -v podman >/dev/null 2>&1; then
    alias p='podman'
fi

# --- Terraform / OpenTofu ---------------------------------------------------
alias tf='terraform'
alias tfi='terraform init'
alias tfp='terraform plan'
alias tfa='terraform apply'
alias tof='tofu'
