#!/usr/bin/env bash

# Script para configurar SSH con GitHub (ed25519 recomendado en 2025/2026)
# Funciona en Linux, macOS y WSL. Ejecutar con bash (no con sh)

set -euo pipefail

# Colores para mejor legibilidad
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_error() {
    printf "${RED}Error: %s${NC}\n" "$1" >&2
}
print_info() {
    printf "${YELLOW}%s${NC}\n" "$1"
}
print_success() {
    printf "${GREEN}%s${NC}\n" "$1"
}
generate_ssh_key() {
    local key_path="$1"
    local email="$2"
    ssh-keygen -t ed25519 -C "$email" -f "$key_path"
}
test_github_connection() {
    local key_path="$1"
    local output
    
    output=$(
    ssh -T git@github.com 2>&1
    ) || true

    if [[ "$output" == *"successfully authenticated"* ]]; then
        return 0
    fi

    printf '%s\n' "$output" >&2
    return 1
}
continue_prompt() {
    read -r -p "Presiona Enter para continuar o Ctrl+C para cancelar..."
}
email() {
    read -r -p "Introduce tu correo de GitHub (o presiona Enter para usar el configurado en git): " EMAIL
}

print_success "=== Configurador de SSH para GitHub (2026 edition) ==="

# ────────────────────────────────────────────────────────────────
# 1. Verificar si ya existe una clave ed25519
# ────────────────────────────────────────────────────────────────
KEY_PATH="$HOME/.ssh/id_ed25519"
PUB_KEY_PATH="${KEY_PATH}.pub"

if [[ -f "$KEY_PATH" && -f "$PUB_KEY_PATH" ]]; then
    print_info "¡Ya existe una clave SSH en: $PUB_KEY_PATH"
    cat "$PUB_KEY_PATH"
    echo
    read -r -p "¿Quieres usar esta clave existente? (S/n): " respuesta
    if [[ ! "$respuesta" =~ ^[Nn]$ ]]; then
        print_success "Usaremos la clave existente."
    else
        print_error "Entonces generaremos una nueva..."
        #ssh-agent -t ed25519 -C "$EMAIL"
        KEY_PATH="${HOME}/.ssh/id_ed25519_$(date +%Y%m%d)"
        PUB_KEY_PATH="${KEY_PATH}.pub"
    fi
fi

# ────────────────────────────────────────────────────────────────
# 2. Generar clave nueva (solo si es necesario)
# ────────────────────────────────────────────────────────────────
email
if [[ ! -f "$PUB_KEY_PATH" ]]; then
    print_info "Generando nueva clave ed25519..."
    print_info "ssh-keygen te pedirá una frase de contraseña y que la confirmes."
    print_info "Puedes dejarla vacía pulsando Enter si no quieres proteger la clave."

    generate_ssh_key "$KEY_PATH" "$EMAIL"

    # Si falla (por ejemplo en sistemas muy viejos), intenta rsa
    if [[ ! -f "$PUB_KEY_PATH" ]]; then
        print_info "ed25519 no funcionó, intentando con rsa-sha2-512..."
        generate_ssh_key "$KEY_PATH" "$EMAIL"
    fi

    print_success "Clave generada en: $KEY_PATH"
fi

# ────────────────────────────────────────────────────────────────
# 3. Iniciar agente ssh y agregar clave
# ────────────────────────────────────────────────────────────────
print_info "Iniciando ssh-agent y agregando la clave... "

# Comprueba si ya existe un agente SSH disponible
if [[ -z "${SSH_AUTH_SOCK-}" ]] || ! ssh-add -l > /dev/null 2>&1; then
    eval "$(ssh-agent -s)" > /dev/null
fi

if ! ssh-add "$KEY_PATH"; then
    print_error "No se pudo agregar la clave al agente."
    print_info "Intenta manualmente: ssh-add $KEY_PATH"
fi

# ────────────────────────────────────────────────────────────────
# 4. Mostrar clave pública y pedir que la copie
# ────────────────────────────────────────────────────────────────
print_info "→ Tu clave pública es: "
cat "$PUB_KEY_PATH"
printf "\n"

print_info "PASOS MANUALES IMPORTANTES: "
print_info "1. Copia TODO el texto de arriba (comienza con ssh-ed25519 o ssh-rsa)"
print_info "2. Ve a → https://github.com/settings/keys"
print_info "3. Haz clic en → New SSH key   o   Add SSH key"
print_info "4. Pon un título descriptivo (ej: \"MacBook 2025\" o \"Laptop Monterrey\")"
print_info "5. Pega la clave en el campo grande"
print_info "6. Haz clic en → Add SSH key"
print_info "7. Si GitHub pide tu contraseña, introdúcela para confirmar"

continue_prompt    

# ────────────────────────────────────────────────────────────────
# 5. Prueba la conexión
# ────────────────────────────────────────────────────────────────
print_info "Probando conexión con GitHub..."
sleep 2

if test_github_connection "$KEY_PATH"; then
    print_success "¡ÉXITO! GitHub te reconoce: "
    print_info "Ahora puedes usar git clone git@github.com:usuario/repo.git"
    print_info "sin pedir usuario/contraseña ni token."
else 
    print_error "La prueba falló."
    print_info "• No has agregado aún la clave en GitHub"
    print_info "• GitHub no reconoce esta clave (quizá copiaste mal la clave pública)"
    print_info "Comando de diagnóstico:"
    print_info "   ssh -vT git@github.com"
fi


print_success "=== Fin del script ==="
