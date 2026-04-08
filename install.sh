#!/data/data/com.termux/files/usr/bin/bash

pkg update -y
pkg upgrade -y

pkg install -y git zsh neovim tmux

echo "Listo entorno base"