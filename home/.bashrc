# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
*i*) ;;
*) return ;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=50000
HISTFILESIZE=50000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
  debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
xterm-color | *-256color) color_prompt=yes ;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
  if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    # We have color support; assume it's compliant with Ecma-48
    # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
    # a case would tend to support setf rather than setaf.)
    color_prompt=yes
  else
    color_prompt=
  fi
fi

if [ "$color_prompt" = yes ]; then
  # https://github.com/git/git/blob/v2.42.0/contrib/completion/git-prompt.sh
  source ~/.git-prompt.sh
  export GIT_PS1_SHOWDIRTYSTATE=1
  export GIT_PS1_SHOWCOLORHINTS=1

  __prompt_command() {
    local exit=$?
    if [ "$exit" -eq 0 ]; then
      local prompt="\[\e[32m\]$"
    else
      local prompt="\[\e[31;1m\]$"
    fi

    local c_blue="\[\033[38;2;114;159;207m\]"  # 114, 159, 207
    local c_yellow="\[\033[38;2;252;233;79m\]" # 252, 233, 79
    local c_green="\[\033[38;2;138;226;52m\]"  # 138, 226, 52
    local c_pink="\[\033[38;2;173;127;168m\]"  # 173, 127, 168
    local c_reset="\[\033[0m\]"

    if [ -f "${KUBECONFIG:-}" ]; then
      local k8s_ctx=" ☁️ $(grep 'current-context' "$KUBECONFIG" 2>/dev/null | awk '{print $2}')"
    fi

    __git_ps1 "${c_blue}\u${c_yellow}@${c_green}\h${c_yellow}:${c_pink}\w${c_reset}${k8s_ctx:-}" "${c_reset}\n${prompt}${c_reset} "
  }

  PROMPT_COMMAND='__prompt_command'
else
  PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm* | rxvt*)
  PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
  ;;
*) ;;
esac

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
  . ~/.bash_aliases
fi

if [ -f ~/.bash_keybindings ]; then
  . ~/.bash_keybindings
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

export PATH="$HOME/.local/bin:$PATH"

export EDITOR=nvim

export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - --no-rehash bash)"

export PIPENV_VENV_IN_PROJECT=1
export PIPENV_VERBOSITY=-1

export N_PREFIX="$HOME/.n"
export PATH="$N_PREFIX/bin:$PATH"

if [ -d "$HOME/.cargo" ]; then
  . "$HOME/.cargo/env"
fi

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH=$BUN_INSTALL/bin:$PATH

if command -v zoxide >/dev/null; then
  eval "$(zoxide init --cmd cd bash)"
  bind -x '"\C-p": __zoxide_zi'
fi

export PATH="/usr/local/cuda/bin:$PATH"
export PATH="/opt/gradle/gradle-8.13/bin:$PATH"

if [ -S "/run/user/1000/docker.sock" ]; then
  export DOCKER_HOST=unix:///run/user/1000/docker.sock
fi

if [ -d "/opt/ffmpeg-cuda" ]; then
  export LD_LIBRARY_PATH="/opt/ffmpeg-cuda/lib:$LD_LIBRARY_PATH"
  export PATH="/opt/ffmpeg-cuda/bin:$PATH"
fi
