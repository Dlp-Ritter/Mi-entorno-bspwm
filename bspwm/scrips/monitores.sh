#!/usr/bin/env bash
#==========================================================
#  monitores.sh
#  Gestion de monitores, escritorios de bspwm y barras polybar
#==========================================================
#
#  PARA QUE SIRVE
#  --------------
#  Ajusta automaticamente bspwm y polybar segun cuantos monitores
#  esten activos:
#
#    - 1 monitor  -> escritorios 1 al 10 en el principal,
#                    barra completa (bar/example).
#    - 2 monitores -> escritorios 1 al 5 en el principal y
#                    6 al 10 en el secundario. Barra completa en
#                    el principal y barra solo con escritorios
#                    (bar/secondary) en el secundario.
#
#  No hay nombres de monitores escritos a mano: el principal es el
#  marcado como "primary" en xrandr y el secundario es cualquier
#  otro monitor activo.
#
#  QUE HACE, EN ORDEN
#  ------------------
#  1. Detecta el monitor principal (el marcado "primary" en xrandr).
#  2. Detecta el monitor secundario: otro monitor con resolucion
#     asignada. Un monitor "connected" pero apagado no cuenta.
#  3. Limpia bspwm: elimina los monitores que ya no estan activos.
#     Sin este paso bspwm sigue recordando el monitor desconectado
#     con sus escritorios 6 al 10, y eso desordena todo.
#  4. Reparte los escritorios segun haya o no monitor secundario.
#  5. Cierra polybar y lo lanza de nuevo: bar/example en el
#     principal y bar/secondary en el secundario, si existe.
#
#  CUANDO EJECUTARLO
#  -----------------
#  - Al iniciar la sesion (desde el bspwmrc).
#  - Cada vez que conectes o desconectes el monitor extra.
#
#  Para activar un monitor que aparece "connected" pero apagado:
#    xrandr --output HDMI-2 --auto --right-of eDP-1
#    ~/.config/bspwm/monitores.sh
#
#  DEPENDENCIAS EN OTROS ARCHIVOS
#  ------------------------------
#  Este script solo funciona si estos cambios existen en la config.
#
#  ~/.config/polybar/config.ini
#    [bar/example]
#      monitor = ${env:MONITOR:}
#        -> el script define la variable MONITOR para elegir en que
#           monitor se dibuja cada barra.
#    [module/bspwm]
#      pin-workspaces = true
#        -> cada barra muestra solo los escritorios de su monitor.
#      label-focused  = %name%
#      label-occupied = %name%
#      label-urgent   = %name%!
#      label-empty    = %name%
#        -> %name% muestra el nombre real del escritorio (6 al 10 en
#           el secundario). Con %index% se veria siempre 1 al 5.
#    [bar/secondary]
#      inherit = bar/example
#      modules-left = bspwm
#      modules-center =
#      modules-right =
#      tray-position = none
#        -> segunda barra con solo los escritorios y sin bandeja
#           (la bandeja solo puede estar en una barra).
#
#  ~/.config/bspwm/bspwmrc
#    Debe contener solo esta linea para monitores y polybar:
#      ~/.config/bspwm/pantallas.sh &
#    Y no debe tener lineas "bspc monitor ... -d ..." ni lanzar
#    polybar por separado, porque se pisarian con este script.
#
#  PERMISOS
#    chmod +x ~/.config/bspwm/pantallas.sh
#
#  SI ALGO FALLA
#  -------------
#  - Ver monitores que ve polybar:   polybar --list-monitors
#  - Ver estado de xrandr:           xrandr --query | grep -E "connected|primary"
#  - Ver monitores en bspwm:         bspc query -M --names
#  - Si no hay monitor "primary":    xrandr --output eDP-1 --primary
#  - Probar una barra a mano:        MONITOR=HDMI-2 polybar -r secondary
#
#  NOTAS
#  -----
#  - Si al quitar el monitor quedan ventanas en el que desaparece,
#    bspwm puede perderlas de vista. Habria que moverlas al principal
#    antes de eliminar el monitor.
#
#==========================================================


#----------------------------------------------------------
# 1. Monitor principal (el marcado como primary en xrandr)
#----------------------------------------------------------
PRINCIPAL=$(xrandr --query | awk '/ primary/{print $1}')

#----------------------------------------------------------
# 2. Monitores realmente activos (con resolucion asignada)
#    y deteccion del secundario
#----------------------------------------------------------
ACTIVOS=$(xrandr --listactivemonitors | awk 'NR>1{print $NF}')
SECUNDARIO=$(echo "$ACTIVOS" | grep -vx "$PRINCIPAL" | head -n1)

#----------------------------------------------------------
# 3. Quitar de bspwm los monitores que ya no estan activos
#----------------------------------------------------------
for m in $(bspc query -M --names); do
    echo "$ACTIVOS" | grep -qx "$m" || bspc monitor "$m" -r
done

#----------------------------------------------------------
# 4. Escritorios segun cuantos monitores haya
#----------------------------------------------------------
if [ -n "$SECUNDARIO" ]; then
    bspc monitor "$PRINCIPAL" -d 1 2 3 4 5
    bspc monitor "$SECUNDARIO" -d 6 7 8 9 10
else
    bspc monitor "$PRINCIPAL" -d 1 2 3 4 5 6 7 8 9 10
fi

#----------------------------------------------------------
# 5. Barras: cerrar polybar y lanzar una por monitor activo
#----------------------------------------------------------
killall -q polybar
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

for m in $ACTIVOS; do
    if [ "$m" = "$PRINCIPAL" ]; then
        MONITOR=$m polybar --reload example &
    else
        MONITOR=$m polybar --reload secondary &
    fi
done
