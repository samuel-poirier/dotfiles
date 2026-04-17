source ~/.local/share/omarchy/default/bash/rc

# Editor used by CLI
export EDITOR="nvim"
export SUDO_EDITOR="$EDITOR"

export DOTNET_USE_POLLING_FILE_WATCHER=1

alias v='nvim'
alias t='tmux'
alias k='kubectl'
alias g='git'
alias y='yazicwd'

export WATCHPACK_POLLING=true

function yazicwd() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}
