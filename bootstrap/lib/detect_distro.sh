#!/usr/bin/env bash
# Universal environment detector — Termux / Proot / Linux
# Autor: xLuffy025 (versión refinada + mejorada)

set -u

# ==== Detect TERMUX ====
detect_termux() {
  if [[ -d "/data/data/com.termux/files/usr" ]]; then
    if [[ -n "
${PREFIX:-}" && "$PREFIX" == *"/data/data/com.termux/files/usr"* ]]; then
      return 0
    fi
  fi
  return 1
}

# ==== Detect PROOT ====
detect_proot() {
  if grep -q "/data/data/com.termux/files/usr" /proc/mounts 2>/dev/null; then
    return 0
  fi
  if grep -q "proot" /proc/1/cmdline 2>/dev/null; then
    return 0
  fi
  if [ -f /etc/os-release ]; then
    grep -q "proot" /etc/os-release && return 0
  fi
  return 1
}

# ==== Detect DISTRO (para Linux/Proot) ====
detect_distro() {
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS="$ID"
    # Normalizar algunos casos
    case "$OS" in
      debian) OS="debian" ;;
      ubuntu) OS="ubuntu" ;;
      arch) OS="arch" ;;
      fedora) OS="fedora" ;;
      rhel) OS="rhel" ;;
      centos) OS="centos" ;;
      opensuse*) OS="opensuse" ;;
      alpine) OS="alpine" ;;
    esac
  elif [ -f /etc/lsb-release ]; then 
    . /etc/lsb-release 
    # ✅ CORREGIDO: DISTRIB_ID (no DISTROB_ID)
    OS=$(echo "$DISTRIB_ID" | tr '[:upper:]' '[:lower:]')
  else
    OS="unknown"
  fi
  
echo "$OS"
}

# ==== Detect PACKAGE MANAGER ====
detect_pkgmgr() {
  local env="$1"
  case "$env" in
    termux)
      echo "pkg"
      ;;
    proot|linux)
      for p in pacman apt dnf yum zypper apk; do
        command -v "$p" >/dev/null 2>&1 && { echo "$p"; return 0; }
      done
      echo "unknown"
      ;;
    *)
      echo "unknown"
      ;;
  esac
}

# ==== Detect USER privilege ====
if [ "$(id -u)" -eq 0 ]; then
  IS_ROOT=1
  SUDO=""
else
  IS_ROOT=0
  SUDO="sudo"
fi

# ==== MAIN DETECTION LOGIC ====
if detect_termux; then
  if detect_proot && [ -f "/etc/os-release" ]; then
    ENV="proot"
  else
    ENV="termux"
  fi
else
  if detect_proot; then
    ENV="proot"
  else
    ENV="linux"
  fi
fi

OS_ID=$(detect_distro)
PKG=$(detect_pkgmgr "$ENV")

# ✅ EXPORTAR todo para que otros scripts lo usen
export ENV OS_ID PKG IS_ROOT SUDO

# ==== Info resumen (solo si es terminal interactiva) ====
if [ -t 1 ]; then
  echo -e "\n🌍 Entorno detectado: ${ENV}"
  echo -e "🐧 Distro: ${OS_ID:-N/A}"
  echo -e "📦 Gestor: ${PKG:-unknown}"
  echo -e "🔑 Root: ${IS_ROOT}\n"
fi
