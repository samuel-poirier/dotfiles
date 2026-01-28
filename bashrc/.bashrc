source ~/.local/share/omakub/defaults/bash/rc

# Editor used by CLI
export EDITOR="nvim"
export SUDO_EDITOR="$EDITOR"

# PS1='[\u@\h \W]\$ '
PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

export PATH=$HOME/.dotnet/tools:$PATH
export PATH=$HOME/.dotnet/:$PATH
export DPRINT_INSTALL="/home/sampoi/.dprint"
export PATH="$DPRINT_INSTALL/bin:$PATH"
export PATH="/opt/Archi/:$PATH"
export DOTNET_USE_POLLING_FILE_WATCHER=1
export DOTNET_ROOT=$HOME/.dotnet/
export QT_QPA_PLATFORM=wayland
export XDG_SESSION_TYPE=wayland
export WAYLAND_DISPLAY=wayland-0

alias v='nvim'
alias t='tmux'
alias k='kubectl'
alias g='git'
alias y='yazicwd'
# Set default vagrant provider virtual box
export VAGRANT_DEFAULT_PROVIDER=virtualbox

[[ -s "/home/sampoi/.gvm/scripts/gvm" ]] && source "/home/sampoi/.gvm/scripts/gvm"

export WATCHPACK_POLLING=true

# Added by tally installer
export PATH="$HOME/.tally/bin:$PATH"

function yazicwd() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}
