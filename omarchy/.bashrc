source ~/.local/share/omarchy/default/bash/rc

# Editor used by CLI
export EDITOR="nvim"
export SUDO_EDITOR="$EDITOR"

export DOTNET_USE_POLLING_FILE_WATCHER=1
export DOTNET_ROOT=/usr/share/dotnet/

alias v='nvim'
alias t='tmux'
alias k='kubectl'
alias g='git'
alias y='yazicwd'

export WATCHPACK_POLLING=true

export DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=0
# ICU value can be found with "pacman -Q icu"
export DOTNET_ICU_VERSION_OVERRIDE=78.3-1
export CLR_ICU_VERSION_OVERRIDE=$DOTNET_ICU_VERSION_OVERRIDE

if [ -d "$HOME/go/bin" ]; then
  PATH=$PATH:$HOME/go/bin
fi

function yazicwd() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}
