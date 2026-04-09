#!/bin/bash

#!/usr/bin/env bash

source "$(dirname "$0")/../lib/detect_distro.sh"
source "$(dirname "$0")/../lib/colors.sh"

msg "Detectada distro: $OS_ID (en ambiente: $ENV)"
msg "Gestor de paquetes: $PKG"

# Paquetes comunes (todas las distros)
COMMON_PACKAGES=(
    "python3"
    "python3-pip"
    "python3-venv"
)

# Paquetes solo para distros completas (NO en Termux)
FULL_DISTRO_PACKAGES=(
    "python3-dev"
    "python3-tk"
    "build-essential"
    "libssl-dev"
    "libffi-dev"
    "libbz2-dev"
)

# Paquetes Termux específicos
TERMUX_PACKAGES=(
    "python"
    "pip"
    "clang"
)

# Módulos pip comunes
PIP_COMMON=(
    "pip"
    "setuptools"
    "wheel"
    "requests"
    "beautifulsoup4"
)

# Módulos pip solo en sistemas completos (causan problemas en Termux)
PIP_FULL_DISTRO=(
    "numpy"
    "pandas"
    "matplotlib"
    "scipy"
    "scikit-learn"
)

install_python_debian() {
    msg "Instalando Python en Debian/Ubuntu..."
    sudo apt update
    sudo apt install -y "${COMMON_PACKAGES[@]}" "${FULL_DISTRO_PACKAGES[@]}"
    ok "Python instalado en Debian/Ubuntu"
}

install_python_arch() {
    msg "Instalando Python en Arch..."
    sudo pacman -Sy
    sudo pacman -S --noconfirm "${COMMON_PACKAGES[@]}" "${FULL_DISTRO_PACKAGES[@]}"
    ok "Python instalado en Arch"
}

install_python_fedora() {
    msg "Instalando Python en Fedora/RHEL..."
    sudo dnf install -y "${COMMON_PACKAGES[@]}" "${FULL_DISTRO_PACKAGES[@]}"
    ok "Python instalado en Fedora/RHEL"
}

install_python_termux() {
    msg "Instalando Python en Termux..."
    pkg update -y
    pkg install -y "${TERMUX_PACKAGES[@]}"
    ok "Python instalado en Termux"
}

install_pip_packages() {
    msg "Instalando módulos pip..."
    
    # Siempre instalar paquetes comunes
    pip install --upgrade "${PIP_COMMON[@]}"
    
    # Solo en distros completas (no Termux)
    if [ "$ENV" != "termux" ]; then
        pip install "${PIP_FULL_DISTRO[@]}"
        ok "Paquetes de distro completa instalados"
    else
        warn "Omitiendo paquetes que no funcionan en Termux"
    fi
}

# ============================================================
# Main
# ============================================================

case "$OS_ID" in
    ubuntu|debian)
        install_python_debian
        ;;
    arch|manjaro)
        install_python_arch
        ;;
    fedora|rhel|centos)
        install_python_fedora
        ;;
    *)
        if [ "$ENV" = "termux" ]; then
            install_python_termux
        else
            err "Distribución no soportada: $OS_ID"
            exit 1
        fi
        ;;
esac

# Instalar paquetes pip al final
install_pip_packages

ok "✅ Instalación de Python completada"

# Crear entorno virtual global
mkdir -p ~/mi-proyecto-python
cd ~/mi-proyecto-python
python -m venv ~/.venv
source ~/.venv/bin/activate

# Actualizar pip y setuptools
pip install --upgrade pip setuptools wheel

# === Instalación de paquetes útiles ===
pip install requests beautifulsoup4 tqdm colorama
pip install ipython rich
pip install pylint black flake8 isort autopep8 mypy
pip install virtualenv virtualenvwrapper
pip install aiohttp selenium
pip install typer click loguru

# Guardar dependencias
pip freeze > ~/.venv/requirements.txt

# Crear alias en .zshrc (si usas zsh)
if [ -f ~/.zshrc ]; then
cat << 'EOF' >> ~/.zshrc

# === Python Dev Aliases ===
alias venv='source ~/.venv/bin/activate'
alias vexit='deactivate'
alias mkvenv='python -m venv ~/.venv && source ~/.venv/bin/activate && pip install --upgrade pip'
alias pyreq='pip freeze > requirements.txt && echo "Guardado en requirements.txt"'
alias pydev='source ~/.venv/bin/activate && echo "🐍 Entorno Python Dev activado"'

EOF
fi

# Crear alias en .bashrc (si usas bash)
if [ -f ~/.bashrc ]; then
cat << 'EOF' >> ~/.bashrc

# === Python Dev Aliases ===
alias venv='source ~/.venv/bin/activate'
alias vexit='deactivate'
alias mkvenv='python -m venv ~/.venv && source ~/.venv/bin/activate && pip install --upgrade pip'
alias pyreq='pip freeze > requirements.txt && echo "Guardado en requirements.txt"'
alias pydev='source ~/.venv/bin/activate && echo "🐍 Entorno Python Dev activado"'

EOF
fi

# Crear mensaje de bienvenida
echo 'echo "🐍 Python Dev listo: usa pydev para activar el entorno."' >> ~/.zshrc

# Limpiar cache
pip cache purge

ok "✅ Instalación completa. Reinicia Termux o ejecuta: source ~/.zshrc"
