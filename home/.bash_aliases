alias ls='ls --group-directories-first --color=auto --human-readable --almost-all --classify -1'
alias vim='nvim'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
[ -x "/usr/bin/batcat" ] && alias cat='batcat --plain --paging=never'

alias ga='git add'
alias gap='git add -p'
alias gcm='git commit'
alias gd='git diff'
alias gl='git lola'
alias gs='git status'
alias gss='git status -s'

alias pbcopy="xclip -selection clipboard"
alias pbpaste="xclip -selection clipboard -o"

alias pn='pnpm'

alias d='docker'
alias dk='docker compose'
alias k='kubectl'
complete -o default -F __start_kubectl k

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

alias temp='cd `mktemp -d`'
