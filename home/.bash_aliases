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

if [ -f "/usr/share/bash-completion/completions/git" ]; then
  source "/usr/share/bash-completion/completions/git"
  __git_complete ga _git_add
  __git_complete gap _git_add
  __git_complete gcm _git_commit
  __git_complete gd _git_diff
  __git_complete gl _git_log
  __git_complete gs _git_status
  __git_complete gss _git_status
fi

alias pbcopy="xclip -selection clipboard"
alias pbpaste="xclip -selection clipboard -o"
alias c="xclip -selection clipboard"
alias p="xclip -selection clipboard -o"

alias pn='pnpm'

alias d='docker'
__docker() {
  type _docker &>/dev/null || source /usr/share/bash-completion/completions/docker
  complete -o default -F _docker d
  _docker "$@"
}
complete -o default -F __docker d
alias dk='docker compose'
alias k='kubectl'
complete -o default -F __start_kubectl k

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

alias temp='cd `mktemp -d`'

yq() {
  docker run --rm -i --security-opt=no-new-privileges --cap-drop=all --network=none mikefarah/yq "$@"
}

pkill() {
  command pkill --echo --ignore-case "$@" 2>/dev/null || true
}
