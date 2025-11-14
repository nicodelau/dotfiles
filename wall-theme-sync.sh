#!/usr/bin/env bash
# ~/.local/bin/wall-theme-sync
# Uso: wall-theme-sync /ruta/a/imagen.jpg [MONITOR]
# - MONITOR opcional: p.ej. "HDMI-A-1". Si no se pasa, aplica a "all".
set -euo pipefail

IMG="${1:-}"
MONITOR="${2:-all}"
LOCK="/tmp/wall-theme-sync.lock"
TMPDIR="$(mktemp -d)"
MAX_RETRIES=3
RETRY_DELAY=0.6

if [[ -z "$IMG" || ! -r "$IMG" ]]; then
  echo "Usage: $0 /path/to/image [MONITOR]" >&2
  exit 1
fi

# herramientas
WAL="$(command -v wal || true)"
SOCAT="$(command -v socat || true)"
WAYBAR_PID="$(pgrep -x waybar || true)"
HYPRPAPER_SERVICE="hyprpaper.service"

# lock simple para evitar concurrencia
exec 9>"$LOCK"
if ! flock -n 9; then
  echo "Otra instancia cambiando wallpaper. Saliendo." >&2
  rm -rf "$TMPDIR"
  exit 0
fi

trap 'rm -rf "$TMPDIR"' EXIT

# 1) Generar paleta con wal (no cambia wallpaper por sí solo)
if [[ -n "$WAL" ]]; then
  "$WAL" -i "$IMG" -o "$TMPDIR/walout" >/dev/null 2>&1 || true
else
  echo "wal no encontrado. Instalá python-pywal (wal) si querés paletas automáticas." >&2
fi

# wal deja ~/.cache/wal/colors.sh
COLORS_SH="$HOME/.cache/wal/colors.sh"
if [[ ! -f "$COLORS_SH" ]]; then
  echo "# no colors generated" >"$COLORS_SH"
fi

# Cargar colores (silencioso si falla)
set +u
source "$COLORS_SH" >/dev/null 2>&1 || true
set -u

BG="${background:-#111827}"
FG="${foreground:-#ffffff}"
ACCENT="${color6:-${color2:-${color4:-$FG}}}"

# Actualizar Waybar style.css (inserta al inicio)
STYLE_CSS="$HOME/.config/waybar/style.css"
if [[ -f "$STYLE_CSS" ]]; then
  # removemos definiciones viejas y añadimos nuevas al inicio
  sed -i '/^@define-color accent /d' "$STYLE_CSS" || true
  sed -i '/^@define-color foreground /d' "$STYLE_CSS" || true
  sed -i '/^@define-color bg-color /d' "$STYLE_CSS" || true
  # insertamos al inicio
  {
    printf '@define-color accent %s;\n@define-color foreground %s;\n@define-color bg-color %s;\n\n' "$ACCENT" "$FG" "$BG"
    cat "$STYLE_CSS"
  } >"$TMPDIR/style.css" && mv "$TMPDIR/style.css" "$STYLE_CSS"
  # recargar waybar si está corriendo
  if pgrep -x waybar >/dev/null 2>&1; then
    pkill -USR1 waybar || true
  fi
  # notificación opcional
  if command -v notify-send >/dev/null 2>&1; then
    notify-send "Tema actualizado" "Colores actualizados en Waybar"
  fi
else
  echo "Waybar style.css no encontrado en $STYLE_CSS — saltando actualización de Waybar." >&2
fi

# Función para encontrar el socket de hyprpaper
find_hyprpaper_sock() {
  # busca sockets .hyprpaper.sock o .socket.sock dentro de /run/user/$UID/hypr
  if [[ -d "/run/user/$UID/hypr" ]]; then
    find /run/user/"$UID"/hypr -maxdepth 2 \( -name '.hyprpaper.sock' -o -name '.socket.sock' \) -print -quit 2>/dev/null || true
  fi
}

# 2) Intentar aplicar el wallpaper vía socket (socat)
if [[ -z "$SOCAT" ]]; then
  echo "socat no encontrado. Instalalo para que el script pueda comunicarse con hyprpaper." >&2
fi

aplicar_via_sock() {
  local sock="$1"
  if [[ -z "$sock" || ! -S "$sock" ]]; then
    return 1
  fi

  # hyprpaper espera comandos: preload <ruta>, wallpaper <monitor>,<ruta>
  if [[ "$MONITOR" == "all" ]]; then
    printf 'preload %s\n' "$IMG" | socat - UNIX-CONNECT:"$sock" || true
    printf 'wallpaper all,%s\n' "$IMG" | socat - UNIX-CONNECT:"$sock"
  else
    printf 'preload %s\n' "$IMG" | socat - UNIX-CONNECT:"$sock" || true
    printf 'wallpaper %s,%s\n' "$MONITOR" "$IMG" | socat - UNIX-CONNECT:"$sock"
  fi
}

# Reintentos: si no hay socket, restart al servicio systemd --user y reintenta
for i in $(seq 1 $MAX_RETRIES); do
  SOCK="$(find_hyprpaper_sock || true)"
  if [[ -n "$SOCK" && -S "$SOCK" && -n "$SOCAT" ]]; then
    if aplicar_via_sock "$SOCK"; then
      echo "Wallpaper aplicado vía socket: $SOCK"
      exit 0
    else
      echo "Error al aplicar vía socket encontrado en $SOCK. Intento $i/$MAX_RETRIES" >&2
    fi
  else
    echo "Socket no encontrado (intento $i/$MAX_RETRIES). Intentando reiniciar $HYPRPAPER_SERVICE..." >&2
    # reinicia service sólo si systemctl --user existe
    if command -v systemctl >/dev/null 2>&1; then
      systemctl --user restart "$HYPRPAPER_SERVICE" >/dev/null 2>&1 || true
    fi
    sleep "$RETRY_DELAY"
  fi
done

# Si llegamos acá, falló la comunicación por socket
echo "No pude aplicar el wallpaper: socket de hyprpaper no disponible tras $MAX_RETRIES intentos." >&2
echo "Comprobá que hyprpaper esté corriendo bajo systemd --user o que no haya instancias duplicadas." >&2
exit 2
