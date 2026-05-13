#!/bin/bash
# ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
# ┃          Liquid Glass - System Accent Color Setter          ┃
# ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

PRIMARY="$1"
SECONDARY="$2"

[ -z "$PRIMARY" ] && exit 1
[ -z "$SECONDARY" ] && SECONDARY="$PRIMARY"

# Strip '#' for hyprland (needs bare hex)
HEX="${PRIMARY#\#}"

# ── 1. EWW: rewrite accent-current.scss ─────────────────────────
cat > ~/.config/eww/accent-current.scss << EOF
// Current accent — rewritten by set-accent.sh
\$accent-primary: ${PRIMARY};
\$accent-secondary: ${SECONDARY};
EOF

# Track current accent for the dot indicator
echo "${PRIMARY}" > ~/.config/eww/current-accent

# ── 2. Hyprland: rewrite colors.conf accent lines ───────────────
COLORS_CONF="$HOME/.config/hypr/colors.conf"
if [ -f "$COLORS_CONF" ]; then
    sed -i "s/^\$accent_primary = .*/\$accent_primary = rgba(${HEX}ff)/" "$COLORS_CONF"
    sed -i "s/^\$col_active_border = .*/\$col_active_border = rgba(${HEX}aa)/" "$COLORS_CONF"
    hyprctl reload 2>/dev/null &
fi

# ── 3. EWW reload (recompiles SCSS with new accent) ─────────────
eww reload

notify-send "Accent Color" "Changed to ${PRIMARY}" -t 1500
