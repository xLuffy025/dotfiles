#!/usr/bin/env bash

# Script para configurar SSH con GitHub (ed25519 recomendado en 2025/2026)
# Funciona en Linux, macOS y WSL. Ejecutar con bash (no con sh)

set -euo pipefail

# Colores para mejor legibilidad
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "\( {GREEN}=== Configurador de SSH para GitHub (2026 edition) === \){NC}\n"

# ────────────────────────────────────────────────────────────────
# 1. Verificar si ya existe una clave ed25519
# ────────────────────────────────────────────────────────────────
KEY_PATH="$HOME/.ssh/id_ed25519"
PUB_KEY_PATH="${KEY_PATH}.pub"

if [[ -f "$PUB_KEY_PATH" ]]; then
    echo -e "\( {YELLOW}¡Ya existe una clave SSH en: \){NC} $PUB_KEY_PATH"
    cat "$PUB_KEY_PATH"
    echo
    read -p "¿Quieres usar esta clave existente? (S/n): " respuesta
    if [[ ! "\( respuesta" =\~ ^[Nn] \) ]]; then
        echo -e "\( {GREEN}Usaremos la clave existente. \){NC}"
    else
        echo -e "\( {RED}Entonces generaremos una nueva... \){NC}"
        KEY_PATH="\( HOME/.ssh/id_ed25519_ \)(date +%Y%m%d)"
        PUB_KEY_PATH="${KEY_PATH}.pub"
    fi
fi

# ────────────────────────────────────────────────────────────────
# 2. Generar clave nueva (solo si es necesario)
# ────────────────────────────────────────────────────────────────
if [[ ! -f "$PUB_KEY_PATH" ]]; then
    echo -e "\n\( {YELLOW}Generando nueva clave ed25519... \){NC}"
    echo "Usa tu correo de GitHub cuando te pregunte"

    ssh-keygen -t ed25519 -C "$(git config user.email || echo "tu-email@ejemplo.com")" -f "$KEY_PATH"

    # Si falla (por ejemplo en sistemas muy viejos), intenta rsa
    if [[ ! -f "$PUB_KEY_PATH" ]]; then
        echo -e "\( {YELLOW}ed25519 no funcionó, intentando con rsa-sha2-512... \){NC}"
        ssh-keygen -t rsa -b 4096 -C "$(git config user.email || echo "tu-email@ejemplo.com")" -f "$KEY_PATH"
    fi

    echo -e "\( {GREEN}Clave generada en: \){NC} $KEY_PATH"
fi

# ────────────────────────────────────────────────────────────────
# 3. Iniciar agente ssh y agregar clave
# ────────────────────────────────────────────────────────────────
echo -e "\n\( {YELLOW}Iniciando ssh-agent y agregando la clave... \){NC}"

eval "$(ssh-agent -s)" > /dev/null
ssh-add "$KEY_PATH" || {
    echo -e "\( {RED}No se pudo agregar la clave al agente. \){NC}"
    echo "Intenta manualmente:   ssh-add $KEY_PATH"
}

# ────────────────────────────────────────────────────────────────
# 4. Mostrar clave pública y pedir que la copie
# ────────────────────────────────────────────────────────────────
echo -e "\n\( {GREEN}→ Tu clave pública es: \){NC}"
cat "$PUB_KEY_PATH"
echo

echo -e "\( {YELLOW}PASOS MANUALES IMPORTANTES: \){NC}"
echo "1. Copia TODO el texto de arriba (comienza con ssh-ed25519 o ssh-rsa)"
echo "2. Ve a → https://github.com/settings/keys"
echo "3. Haz clic en → New SSH key   o   Add SSH key"
echo "4. Pon un título descriptivo (ej: \"MacBook 2025\" o \"Laptop Monterrey\")"
echo "5. Pega la clave en el campo grande"
echo "6. Haz clic en → Add SSH key"
echo

# ────────────────────────────────────────────────────────────────
# 5. Prueba la conexión
# ────────────────────────────────────────────────────────────────
echo -e "\( {YELLOW}Probando conexión con GitHub... \){NC}"
sleep 2

ssh -T git@github.com && {
    echo -e "\n\( {GREEN}¡ÉXITO! GitHub te reconoce: \){NC}"
    echo "Ahora puedes usar git clone git@github.com:usuario/repo.git"
    echo "sin pedir usuario/contraseña ni token."
} || {
    echo -e "\n\( {RED}La prueba falló. Posibles razones: \){NC}"
    echo "• No has agregado aún la clave en GitHub"
    echo "• La clave copiada tiene espacios o saltos de línea extra"
    echo "• Problemas con el agente ssh"
    echo
    echo "Comando de diagnóstico:"
    echo "   ssh -vT git@github.com"
}

echo -e "\n\( {GREEN}¡Listo! Si necesitas ayuda con algún paso dime. \){NC}"
echo "Puedes guardar este script por si lo necesitas en otra máquina."
