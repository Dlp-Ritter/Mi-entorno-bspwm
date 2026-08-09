#!/usr/bin/env bash
# display-menu.sh — menú tipo xfce4-display-settings para elegir modo
# al conectar un proyector/pantalla externa vía HDMI.

set -euo pipefail

INTERNAL=$(xrandr --query | grep " connected" | grep -E "eDP|LVDS" | cut -d" " -f1 | head -n1)
EXTERNAL=$(xrandr --query | grep " connected" | grep -vE "eDP|LVDS" | cut -d" " -f1 | head -n1)

# Fallback si nunca ha corrido el rotador (nitrogen no usa esta variable)
WALLPAPER="$HOME/Pictures/wallpaper.jpg"

reapply_wallpaper() {
    sleep 1   # da tiempo a que xrandr aplique el nuevo layout antes de redibujar

    if command -v nitrogen >/dev/null; then
        nitrogen --restore
    elif command -v feh >/dev/null; then
        CURRENT_FILE="$HOME/.cache/current_wallpaper"
        if [[ -f "$CURRENT_FILE" ]]; then
            IMG=$(<"$CURRENT_FILE")
        else
            IMG="$WALLPAPER"
        fi
        ACTIVE_OUTPUTS=$(xrandr --query | grep " connected" | wc -l)
        IMAGES=()
        for ((i=0; i<ACTIVE_OUTPUTS; i++)); do
            IMAGES+=("$IMG")
        done
        feh --bg-fill "${IMAGES[@]}"
    fi
}

if [[ -z "$EXTERNAL" ]]; then
    notify-send "Pantallas" "No se detectó ninguna pantalla externa conectada."
    exit 0
fi

OPTIONS="Solo interna
Solo externa
Duplicar (mirror)
Extender (derecha)
Extender (izquierda)"

CHOICE=$(echo "$OPTIONS" | rofi -dmenu -p "Modo de pantalla" -i)

case "$CHOICE" in
    "Solo interna")
        xrandr --output "$EXTERNAL" --off --output "$INTERNAL" --auto
        ;;
    "Solo externa")
        xrandr --output "$INTERNAL" --off --output "$EXTERNAL" --auto
        ;;
    "Duplicar (mirror)")
        xrandr --output "$INTERNAL" --auto --output "$EXTERNAL" --auto --same-as "$INTERNAL"
        ;;
    "Extender (derecha)")
        xrandr --output "$INTERNAL" --auto --output "$EXTERNAL" --auto --right-of "$INTERNAL"
        ;;
    "Extender (izquierda)")
        xrandr --output "$INTERNAL" --auto --output "$EXTERNAL" --auto --left-of "$INTERNAL"
        ;;
    *)
        exit 0
        ;;
esac

reapply_wallpaper

notify-send "Pantallas" "Modo aplicado: $CHOICE"

command -v bspc >/dev/null && bspc wm -r || true
