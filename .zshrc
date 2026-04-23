# =============================================
# ZSHRC OPTIMIZADO PARA TERMUX + P10K
# =============================================

# === Powerlevel10k Instant Prompt ===
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# === Configuración básica de Oh My Zsh ===
export ZSH="$HOME/.oh-my-zsh"
export EDITOR=nvim
#ZSH_THEME="powerlevel10k/powerlevel10k"

# Desactivar actualizaciones automáticas (mejora rendimiento en Termux)
DISABLE_AUTO_UPDATE="true"
DISABLE_MAGIC_FUNCTIONS="true"
DISABLE_COMPFIX="true"

# Plugins
plugins=(git 
	zsh-autosuggestions 
	zsh-syntax-highlighting 
	fast-syntax-highlighting 
	zsh-autocomplete
  z 
  colored-man-pages
  command-not-found
  )

source $ZSH/oh-my-zsh.sh


# === Powerlevel10k configuración ===
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# === Optimizaciones de rendimiento ===
zstyle ':completion:*' completer _complete _ignored _approximate
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Reducir tiempo de autocompletado
setopt NO_BG_NICE
setopt NO_HUP
setopt NO_LIST_BEEP

# Historial optimizado
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt SHARE_HISTORY


# alias ohmyzsh="mate ~/.oh-my-zsh"
source ~/powerlevel10k/powerlevel10k.zsh-theme

bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line


#Alias basicos
alias ll='lsd -lh --group-dirs=first'
alias la='lsd -a --group-dirs=first'
alias l='lsd --group-dirs=first'
alias lla='lsd -lha --group-dirs=first'
alias ls='lsd --group-dirs=first'
alias cat='bat'

alias lls='ls -la'
alias cls='clear'
alias gs='git status'
alias py='python'
alias nv='nvim'
alias tup="~/update.sh"
alias fix-perms='chmod -R 755 *'
alias up='pkg update -y && pkg upgrade -y'

# Alias proot-distro

alias arch='proot-distro login archlinux --user xluffy025'
alias arch='proot-distro login archlinux'
alias ubuntu='proot-distro login ubuntu'
alias debian='proot-distro login debian'
alias rocky='proot-distro login rockylinux'

alias copiar='termux-clipboard-set'
alias pegar='termux-clipboard-get'

# === Integración con tmux ===
if [[ -z "$TMUX" ]]; then
  tmux attach || tmux new-session
fi 

# === Linux curso
alias reg='~/termux-setup/dotfile/linux_clases/registra_ejercicio.sh'
alias pro='~/termux-setup/dotfile/linux_clases/progreso.sh'
alias aput='~/termux-setup/dotfile/linux_clases/abrir_apuntes.sh'

# --- Auto iniciar SSH agent y cargar clave ---
if [ -z "$SSH_AUTH_SOCK" ]; then
  eval "$(ssh-agent -s)" > /dev/null
  ssh-add ~/.ssh/id_ed25519 > /dev/null 2>&1
fi

export TERM=xterm-256color
eval "$(starship init zsh)"
alias gs='git status'
alias ga='git add .'
alias gc='git commit -m'
alias gp='git push'
alias gpo='git push origin'
alias gpl='git pull'
alias gco='git checkout'
alias gl='git log --oneline --graph --decorate'
alias gundo='git reset --soft HEAD~1'


alias config='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# Mensaje de bienvenida opcional
echo "🚀 Termux listo con Zsh + P10k | $(date '+%H:%M')"

# === Python Dev Aliases ===
alias venv='source ~/.venv/bin/activate'
alias vexit='deactivate'
alias mkvenv='python -m venv ~/.venv && source ~/.venv/bin/activate && pip install --upgrade pip'
alias pyreq='pip freeze > requirements.txt && echo "Guardado en requirements.txt"'
alias pydev='source ~/.venv/bin/activate && echo "🐍 Entorno Python Dev activado"'

echo "🐍 Python Dev listo: usa pydev para activar el entorno."

# === Node.js Aliases ===
alias noj='nose index.js'

