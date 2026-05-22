# General-purpose aliases.

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias -- -='cd -'

# ls — colorize via dircolors if available; other ls aliases inherit through
# bash's recursive alias expansion of the first word.
if [ -x /usr/bin/dircolors ]; then
    if [ -r ~/.dircolors ]; then
        eval "$(dircolors -b ~/.dircolors)"
    else
        eval "$(dircolors -b)"
    fi
    alias ls='ls --color=auto'
fi
alias ll='ls -alhF'
alias la='ls -A'
alias l='ls -CF'
alias lt='ls -alhFtr'

# Safer
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -pv'

# Misc helpers
alias h='history'
alias c='clear'
alias path='echo -e "${PATH//:/\\n}"'
alias ports='ss -tulnp'
alias myip='curl -s ifconfig.me; echo'
alias serve='python -m http.server'
alias json='python -m json.tool'
alias reload='source ~/.bashrc'
alias dotfiles='cd ~/dotfiles'

# Disk / processes
alias df='df -h'
alias du='du -h'
alias dus='du -sh'
alias free='free -h'
alias psg='ps aux | grep -v grep | grep -i'

# Color
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias watch='watch --color'

# Desktop notification on long-running commands: `sleep 10; alert`
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
