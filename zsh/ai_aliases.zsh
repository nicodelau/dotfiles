# ==============================================================================
# Zsh Aliases & Functions for Google Antigravity CLI (agy) & Claude Code
# Location: ~/Documents/GitHub/dotfiles/zsh/ai_aliases.zsh
# Source this file in your ~/.zshrc
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. Inteligente AI Router Command (ai)
# ------------------------------------------------------------------------------
# Decide on-the-fly qué agente y modelo usar según el tamaño del codebase
# o mediante flags explícitas.
ai() {
  # Asegurar que estamos en un repositorio git (necesario para medir tamaño)
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "⚠️  No se detectó un repositorio git. Inicializando repositorio..."
    git init
  fi

  # Crear MEMORY.md si no existe
  if [ ! -f "MEMORY.md" ]; then
    agy-init
  fi

  local force_claude=false
  local force_agy=false
  local use_fast=false
  local remaining_args=()

  # Parsear argumentos de entrada del router
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -c|--claude)
        force_claude=true
        shift
        ;;
      -a|--agy)
        force_agy=true
        shift
        ;;
      -f|--fast)
        use_fast=true
        shift
        ;;
      *)
        remaining_args+=("$1")
        shift
        ;;
    esac
  done

  # Establecer el límite de tokens estimado (800 KB de código fuente ~ 200k tokens)
  local token_threshold_bytes=800000
  local codebase_bytes=0

  # Calcular tamaño de los archivos bajo seguimiento de Git (ignora dependencias/ignores)
  codebase_bytes=$(git ls-files -z 2>/dev/null | xargs -0 stat -c %s 2>/dev/null | awk '{s+=$1} END {print s}')
  if [ -z "$codebase_bytes" ]; then
    codebase_bytes=0
  fi

  local estimated_tokens=$((codebase_bytes / 4))

  echo -e "\033[0;34m[AI Router]\033[0m Tamaño estimado del Workspace: ~${estimated_tokens} tokens (${codebase_bytes} bytes)"

  # Toma de decisión
  if [ "$force_claude" = true ]; then
    echo -e "\033[0;32m[AI Router]\033[0m Forzando desvío a Claude Code..."
    claude "${remaining_args[@]}"
  elif [ "$force_agy" = true ]; then
    if [ "$use_fast" = true ]; then
      echo -e "\033[0;32m[AI Router]\033[0m Forzando desvío a Antigravity (Gemini 3.7 Flash)..."
      agy --model=gemini-3.7-flash-high "${remaining_args[@]}"
    else
      echo -e "\033[0;32m[AI Router]\033[0m Forzando desvío a Antigravity (Claude Sonnet 4.6)..."
      agy --model=claude-sonnet-4-6 "${remaining_args[@]}"
    fi
  elif [ "$use_fast" = true ]; then
    echo -e "\033[0;32m[AI Router]\033[0m Modo rápido activado. Ruteando a Antigravity (Gemini 3.7 Flash)..."
    agy --model=gemini-3.7-flash-high "${remaining_args[@]}"
  elif [ "$codebase_bytes" -gt "$token_threshold_bytes" ]; then
    echo -e "\033[0;33m[AI Router] 📂 Workspace grande (>200K tokens). Ruteando a Claude Code (Enterprise Web limits)...\033[0m"
    claude "${remaining_args[@]}"
  else
    echo -e "\033[0;32m[AI Router] 📂 Workspace mediano/chico. Ruteando a Antigravity CLI (Claude Sonnet 4.6)...\033[0m"
    
    # Ejecutar Antigravity y capturar estado de salida para fallback
    agy --model=claude-sonnet-4-6 "${remaining_args[@]}"
    local exit_code=$?

    # Si sale con error (por ejemplo, límite de quota o tokens de contexto)
    if [ $exit_code -ne 0 ]; then
      echo -e "\n\033[0;31m[AI Router] ⚠️  La sesión de Antigravity terminó inesperadamente (código de salida: $exit_code).\033[0m"
      echo -n "¿Deseas hacer fallback inmediato a Claude Code? (s/n): "
      read -r fallback_res
      if [[ "$fallback_res" =~ ^[SsYy]$ ]]; then
        echo -e "\033[0;32m[AI Router] 🚀 Lanzando Claude Code...\033[0m"
        claude "${remaining_args[@]}"
      fi
    fi
  fi
}

# ------------------------------------------------------------------------------
# 2. Aliases Core (Mapeos Directos)
# ------------------------------------------------------------------------------
alias af="agy --model=gemini-3.7-flash-high"
alias ad="agy --model=claude-sonnet-4-6"
alias ap="agy --model=gemini-3.1-pro-high"
alias as="agy --sandbox"
alias ac="agy --continue"
alias c="claude"

# ------------------------------------------------------------------------------
# 3. Funciones de Inicialización
# ------------------------------------------------------------------------------
agy-init() {
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "⚠️  No se detectó un repositorio git. Inicializando repositorio..."
    git init
  fi

  if [ -f "MEMORY.md" ]; then
    echo "ℹ️  MEMORY.md ya existe en la raíz del proyecto."
  else
    echo "📝 Creando plantilla de MEMORY.md..."
    cat << 'EOF' > MEMORY.md
# Memoria de Desarrollo - Nombre del Proyecto

## 1. Propósito y Alcance
- [Breve descripción de una o dos frases sobre qué hace este proyecto]

## 2. Arquitectura y Tecnologías
- **Core Stack:** [Tecnologías principales, ej: Python 3.12, FastAPI, PostgreSQL]
- **Patrones:** [Ej: Clean Architecture, Repositorios, DDD]
- **Restricciones:** [Ej: No usar librerías externas para JWT, mantener cobertura >90%]

## 3. Decisiones Arquitectónicas Clave
- **2026-08-26 - Inicialización**: Configuración base del proyecto y definición de estructura inicial.

## 4. Estado Actual y Foco
- **Foco Actual:** Inicialización de la base de código.
- **Bloqueantes:** Ninguno.

## 5. Próximos Pasos (Roadmap Inmediato)
- [ ] Implementar estructura de directorios
- [ ] Configurar tests básicos
EOF
    echo "✅ MEMORY.md creado con éxito!"
  fi
}
