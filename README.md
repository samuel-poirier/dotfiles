# Introduction

This repository contains all of my common dotfiles configuration used used for my development setup. The repository is setup to be easily cloned to a `~/dotfiles` directory and use `GNU stow` to setup symlinks on any new environment quickly.

Make sure you have `GNU stow` installed to proceed with the following steps:

Once the repository is cloned in `~/dotfiles`

`stow` will configure symlinks with the following format: `<application Id>/<path where it will be created>`

Use the `stow` command with the `application Id` you want to install:

```shell
stow nvim && stow profile && stow tmux && stow editorconfig && stow vimrc && stow vscode
```

## Plugin config instructions

### tmux plugin manager

To get the configuration working for tmux, follow these steps:

1. Clone the tmux plugin manager repo

```shell
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

2. Open a tmux session, then use `<C-a>I` to trigger the tmux plugin install

### lazygit installation

My Neovim config uses lazygit as it's default git tool. To install, make sure you update your arch packages using:

```bash
sudo pacman -Sy
```

Then install lazygit:

```bash
sudo pacman -S lazygit
```

## Install Nerdfont for nvim

```bash
mkdir -p ~/.fonts
curl -L https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/JetBrainsMono.zip --output ~/Downloads/JetBrainsMono.zip
unzip ~/Downloads/JetBrainsMono.zip -d ~/.fonts
fc-cache -f -v
```


## C# Roslyn nvim LSP download source

Look for "Microsoft.CodeAnalysis.LanguageServer.<platform>" on:

https://dev.azure.com/azure-public/vside/_artifacts/feed/msft_consumption
