#!/usr/bin/env bash
# Colores y funciones comunes para scripts

# 🎨 Colores
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
CYAN="\033[1;36m"
RED="\033[1;31m"
RESET="\033[0m"

# 🧩 Funciones de mensajes
msg()  { echo -e "📦 ${1}"; }
ok()   { echo -e "✅ ${1}"; }
warn() { echo -e "⚠️ ${1}"; }
err()  { echo -e "❌ ${1}" >&2; }
