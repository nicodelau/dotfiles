#!/usr/bin/env bash
set -euo pipefail

IMG="$1"
CONF="$HOME/.config/hypr/hyprpaper.conf"
if [[ -z "$IMG" || ! -r "$IMG" ]]; then
  echo "Uso: $0 /ruta/a/imagen.jpg (archivo debe existir)"
  exit 1
fi

HYPRCTL="$(command -v hyprctl || true)"
if [[ -z "$HYPRCTL" ]]; then
  echo "hyprctl no encontrado"
  exit 2
fi

# preload (opcional)
"$HYPRCTL" hyprpaper preload "$IMG" || true

# obtener nombres reales de monitores (ej: HDMI-A-1, DP-1)
MONS=()
while IFS= read -r line; do
  if [[ $line =~ ^Monitor[[:space:]]+([A-Za-z0-9_.-]+) ]]; then
    MONS+=("${BASH_REMATCH[1]}")
  fi
done < <("$HYPRCTL" monitors 2>/dev/null || true)

if [[ ${#MONS[@]} -eq 0 ]]; then
  echo "No pude detectar monitores; aplicando global"
  "$HYPRCTL" hyprpaper wallpaper ",$IMG"
else
  for m in "${MONS[@]}"; do
    echo "Aplicando a monitor: $m"
    "$HYPRCTL" hyprpaper wallpaper "${m},$IMG"
    awk '!/^preload = / && !/^wallpaper = / { print }' "$CONF" >"${CONF}.tmp"
    printf "preload = %s\nwallpaper = ,%s\n\n" "$IMG" "$IMG" >"$CONF"
  done
fi

# --- A partir de aquí: cambio dinámico de colores para Waybar ---

WAL="$(command -v wal || true)"
STYLE_CSS="$HOME/.config/waybar/style.css"

if [[ -n "$WAL" ]]; then
  # Generar paleta pero sin cambiar fondo
  "$WAL" -i "$IMG" -o /tmp/walout >/dev/null 2>&1 || true

  COLORS_SH="$HOME/.cache/wal/colors.sh"
  if [[ ! -f "$COLORS_SH" ]]; then
    echo "# no colors generated" >"$COLORS_SH"
  fi

  # Cargar colores pywal
  set +u
  source "$COLORS_SH" || true
  set -u

  # Obtener colores para @define-color
  BG="${background:-#111827}"
  FG="${foreground:-#ffffff}"
  ACCENT="${color6:-${color2:-${color4:-$foreground}}}"

  # Limpiar definiciones previas del style.css por si existen
  sed -i '/^@define-color bg-color /d' "$STYLE_CSS"
  sed -i '/^@define-color foreground /d' "$STYLE_CSS"
  sed -i '/^@define-color accent /d' "$STYLE_CSS"

  # Insertar nuevas definiciones al inicio del archivo
  sed -i "1i @define-color accent ${ACCENT};\n@define-color foreground ${FG};\n@define-color bg-color ${BG};" "$STYLE_CSS"

  # Recargar Waybar para que tome los nuevos colores
  # Terminate already running bar instances
  killall -q waybar
  # Launch main
  waybar &
fi
