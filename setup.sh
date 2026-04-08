#!/usr/bin/env bash 
set -e 

echo "=== Configuracion dotfiles + bootstrap ==="

# Clonar bare repo si no existe 
if [ ! -d "$HOME/.dotfiles" ]; then 
  git clone --bare https://github.com/xLuffy025/dotfiles.git "$HOME/.dotfiles"
fi 

alias config='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME' 2>/dev/null || true
config config --local status.showUntrackedFile no 

# Restaurar archivos (incluyendo bootstrap)
config checkout --force

echo "bootstrap copiado correctamente."
echo "Para ejecutar el instalador completo:"
echo "  cd ~/bootstrap && ./install.sh"
