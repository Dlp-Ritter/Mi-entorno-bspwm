#!/usr/bin/env bash
#
# battery.sh — reporta el estado de la batería para polybar (custom/script)
# sin depender de que internal/battery adivine bien el nombre de tu hardware.
#
# Detecta automáticamente la primera BAT* que encuentre en
# /sys/class/power_supply/. Si tienes varias baterías, puedes fijar
# el nombre a mano con la variable BATTERY_NAME más abajo.

set -euo pipefail

POWER_SUPPLY_DIR="/sys/class/power_supply"

# --- Detección automática de la batería -----------------------------
BATTERY_NAME="${BATTERY_NAME:-}"
if [[ -z "$BATTERY_NAME" ]]; then
    for dev in "$POWER_SUPPLY_DIR"/BAT*; do
        [[ -d "$dev" ]] && BATTERY_NAME="$(basename "$dev")" && break
    done
fi

BATTERY_PATH="$POWER_SUPPLY_DIR/$BATTERY_NAME"

if [[ -z "$BATTERY_NAME" || ! -d "$BATTERY_PATH" ]]; then
    echo " sin batería"
    exit 0
fi

CAPACITY="$(cat "$BATTERY_PATH/capacity" 2>/dev/null || echo 0)"
STATUS="$(cat "$BATTERY_PATH/status" 2>/dev/null || echo Unknown)"
# Status típicamente: Charging | Discharging | Full | Not charging | Unknown

# --- Icono según estado y nivel (Nerd Font / FontAwesome) ------------
if [[ "$STATUS" == "Charging" ]]; then
    ICON=""
elif [[ "$STATUS" == "Full" ]]; then
    ICON=""
else
    if   (( CAPACITY >= 90 )); then ICON=""
    elif (( CAPACITY >= 60 )); then ICON=""
    elif (( CAPACITY >= 35 )); then ICON=""
    elif (( CAPACITY >= 15 )); then ICON=""
    else ICON=""
    fi
fi

echo "${ICON} ${CAPACITY}%"
