#!/usr/bin/env bash
BATTERY_PATH="/sys/class/power_supply/BAT0"
ADAPTER_PATH="/sys/class/power_supply/AC" # Revisa con `ls /sys/class/power_supply` si se llama AC o ACAD

[[ -d "$BATTERY_PATH" ]] || exit 0

CAPACITY=$(<"$BATTERY_PATH/capacity")
STATUS=$(<"$BATTERY_PATH/status")

# Colores: naranja para el estado normal, verde cuando está cargando
COLOR_NORMAL="%{F#ffb52a}"
COLOR_CHARGING="%{F#55aa55}"
COLOR_RESET="%{F-}"

# Definir Íconos según la carga
if [ "$CAPACITY" -le 30 ]; then
    ICON=""
elif [ "$CAPACITY" -le 70 ]; then
    ICON=""
else
    ICON=""
fi

if [ "$STATUS" = "Charging" ]; then
    # Ícono + porcentaje en verde para que se note de un vistazo que está cargando
    ICON=""  # opcional: ícono de enchufe en vez del ícono de nivel
    echo "${COLOR_CHARGING}${ICON} ${CAPACITY}%${COLOR_RESET}"
elif [ "$STATUS" = "Full" ]; then
    echo "${COLOR_NORMAL}${COLOR_RESET} ${CAPACITY}%"
else
    # Descargando
    echo "${COLOR_NORMAL}${ICON}${COLOR_RESET} ${CAPACITY}%"
fi
