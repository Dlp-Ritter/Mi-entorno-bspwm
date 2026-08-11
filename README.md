## instalar dependencias necesarias para el proceso:

``` bash
sudo apt install build-essential git vim libxcb-util0-dev libxcb-ewmh-dev libxcb-randr0-dev libxcb-icccm4-dev libxcb-keysyms1-dev  libxcb-xinerama0-dev libasound2-dev libxcb-xtest0-dev libxcb-shape0-dev libxcb-xkb-dev libxinerama1 libxinerama-dev
```

## Instalar el WM y sxhkd

``` bash
git clone https://github.com/baskerville/bspwm.git
git clone https://github.com/baskerville/sxhkd.git
```

ahora compilamos cada uno

``` bash
cd bspwm
make
sudo make install

cd sxhkd
make
sudo make install
```

Crear los directorios de configuración de bspwm y sxhkd en .config.
``` bash
mkdir ~/.config/{bspwm,sxhkd}
```

Copiar los ejemplos de configuracion de bspwm a las carpetas creadas

``` bash
cp bspwm/examples/bspwmrc .config/bspwm/
cp bspwm/examples/sxhkdrc .config/sxhkd/
```

Configurar algunas cuestiones de sxhkd, algunas ya estan en el mismo fichero de mis propios dotfiles, asi que dejarlos, para scripts de configuracion hacer esto:

Script de resize de ventana flotante:

``` bash
mkdir ~/.config/bspwm/scrips
touch ~/.config/bspwm/scrips/bspwm_resize
chmod +x ~/.config/bspwm/scrips/bspwm_resize
```

Script - bspwm_resize 

``` bash
#!/usr/bin/env dash 

if bspc query -N -n focused.floating > /dev/null; then 
	step=20 
else 
	step=100 
fi 

case "$1" in 
	west) dir=right; falldir=left; x="-$step"; y=0;; 
	east) dir=right; falldir=left; x="$step"; y=0;; 
	north) dir=top; falldir=bottom; x=0; y="-$step";; 
	south) dir=top; falldir=bottom; x=0; y="$step";; 
esac 

bspc node -z "$dir" "$x" "$y" || bspc node -z "$falldir" "$x" "$y"
```

## Polybar

Dependencias necesarias 

``` bash
sudo apt install cmake cmake-data pkg-config python3-sphinx libcairo2-dev libxcb1-dev libxcb-util0-dev libxcb-randr0-dev libxcb-composite0-dev python3-xcbgen xcb-proto libxcb-image0-dev libxcb-ewmh-dev libxcb-icccm4-dev libxcb-xkb-dev libxcb-xrm-dev libxcb-cursor-dev libasound2-dev libpulse-dev libjsoncpp-dev libmpdclient-dev libuv1-dev libnl-genl-3-dev
```

ahora clonar polybar:

``` bash
git clone --recursive https://github.com/polybar/polybar
cd polybar
mkdir build
cd build
cmake ..

make -j$(nproc)
sudo make install
```

## Picom

Dependecias:

``` bash
sudo apt install meson ninja-build libxext-dev libxcb1-dev libxcb-damage0-dev libxcb-xfixes0-dev libxcb-shape0-dev libxcb-render-util0-dev libxcb-render0-dev libxcb-composite0-dev libxcb-image0-dev libxcb-present-dev libxcb-xinerama0-dev libxcb-randr0-dev libxcb-util-dev libpixman-1-dev libdbus-1-dev libconfig-dev libgl1-mesa-dev libgl-dev libegl-dev libepoxy-dev libpcre2-dev libevdev-dev libev-dev libx11-xcb-dev libxcb-glx0-dev uthash-dev
```

ahora clonar picom

``` bash
git clone https://github.com/yshui/picom.git
```

Configuraciones de picom

``` bash
cd picom
git submodule update --init --recursive
meson setup --buildtype=release build
ninja -C build
sudo ninja -C build install
```

Fuentes

Descargar la fuente Hack Nerds Fonts desde esta web: https://www.nerdfonts.com/; y colocarlo a esta ruta:

``` bash
cd /usr/local/share/fonts
sudo mv ~/Descargas/Hack.zip .
sudo unzip Hack.zip
sudo rm Hack.zip
```

Instalar Zsh

``` bash
sudo apt install zsh
```

Instalar Feh y pcmanfm

``` bash
sudo apt install feh pcmanfm
```



Herramientas Varias

``` bash
sudo apt install scrub #Borrado seguro
```

Configurar las teclas de funcion multimedia

``` bash
sudo apt install brightnessctl playerctl arandr rfkill rofi x11-utils

#Instalar mons para varios monitores y proyectores
git clone --recursive https://github.com/Ventto/mons.git
cd mons
sudo make install


```

sxhkd:

``` bash
# ======================================================
# Teclas de Función (F1 - F12) - ThinkPad Yoga S1
# ======================================================

# F1: Silenciar Audio
XF86AudioMute
    wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle

# F2: Bajar Volumen (-5%)
XF86AudioLowerVolume
    wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-

# F3: Subir Volumen (+5%)
XF86AudioRaiseVolume
    wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+

# F4: Silenciar / Activar Micrófono
XF86AudioMicMute
    wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle

# F5: Bajar Brillo Pantalla (-10%)
XF86MonBrightnessDown
    brightnessctl set 10%-

# F6: Subir Brillo Pantalla (+10%)
XF86MonBrightnessUp
    brightnessctl set +10%

# F7: Gestión de Pantallas y Monitores
#XF86Display
#    $HOME/.config/bspwm/scrips/display-menu.sh
    
super + p
	$HOME/.config/bspwm/scrips/display-menu.sh

# F8: Alternar Wi-Fi (Modo Avión)
XF86WLAN
    rfkill toggle wlan

# F9: Ajustes / Menú Rofi
XF86Tools
    rofi -show drun

# F10: Búsqueda Rofi
XF86Search
    rofi -show run

# F11: Conmutador / Vista de Ventanas Abiertas
XF86LaunchA
    rofi -show window

# F12: Abrir Gestor de Archivos (en el directorio personal)
XF86Explorer
    pcmanfm ~
```

Script para el gestion de pantallas y proyector: en /bspwm/scrips

display-menu.sh
``` bash
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

reapply_wallpaper

notify-send "Pantallas" "Modo aplicado: $CHOICE"

command -v bspc >/dev/null && bspc wm -r || true
```

opcional con feh, un script para cambiar el fondo de manera autoamtica, probar si conviven bien con el script de arriba:

wallpaper-rotate.sh
``` bash
#!/usr/bin/env bash
# wallpaper-rotate.sh — rota wallpapers en orden secuencial (no aleatorio)
# cada N minutos, usando feh, soportando cualquier formato de imagen
# y respetando multi-monitor (duplica la misma imagen en cada pantalla activa).

set -euo pipefail

WALLPAPER_DIR="$HOME/Pictures/wallpapers"   # ajusta a tu carpeta real
INTERVAL_SECONDS=600                          # 10 minutos
STATE_FILE="$HOME/.cache/wallpaper_index"
CURRENT_FILE="$HOME/.cache/current_wallpaper"  # leído también por display-menu.sh

mkdir -p "$(dirname "$STATE_FILE")"

# Extensiones soportadas (cualquier formato común de imagen)
shopt -s nullglob nocaseglob
IMAGES=("$WALLPAPER_DIR"/*.{jpg,jpeg,png,bmp,webp,gif,tiff,tif})
shopt -u nocaseglob

if [[ ${#IMAGES[@]} -eq 0 ]]; then
    notify-send "Wallpaper" "No se encontraron imágenes en $WALLPAPER_DIR"
    exit 1
fi

# Orden estable y determinista (alfabético), no depende del orden del filesystem
IFS=$'\n' IMAGES=($(printf '%s\n' "${IMAGES[@]}" | sort)); unset IFS

apply_current() {
    local img="$1"
    ACTIVE_OUTPUTS=$(xrandr --query | grep " connected" | wc -l)
    local ARGS=()
    for ((i=0; i<ACTIVE_OUTPUTS; i++)); do
        ARGS+=("$img")
    done
    feh --bg-fill "${ARGS[@]}"
    echo "$img" > "$CURRENT_FILE"
}

# Índice actual (persiste entre reinicios del rotador)
if [[ -f "$STATE_FILE" ]]; then
    INDEX=$(<"$STATE_FILE")
else
    INDEX=0
fi

while true; do
    # Si el índice quedó fuera de rango (ej. borraste imágenes), reinicia
    if (( INDEX >= ${#IMAGES[@]} )); then
        INDEX=0
    fi

    CURRENT_IMG="${IMAGES[$INDEX]}"
    apply_current "$CURRENT_IMG"
    echo "$INDEX" > "$STATE_FILE"

    sleep "$INTERVAL_SECONDS"

    INDEX=$(( (INDEX + 1) % ${#IMAGES[@]} ))
done
```

Instalar oh my zsh y powerlevel10k

Seguir las guias oficiales de cada proyecto.

Version recomenda por Claudio xD
``` bash
### Instalar Oh My Zsh (comando oficial del repo)
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

### Instalar Powerlevel10k (método oficial "Oh My Zsh")
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"

#Luego edita tu `~/.zshrc` y busca la línea `ZSH_THEME=`, cámbiala a:
ZSH_THEME="powerlevel10k/powerlevel10k"

#Fuentes recomendadas
mkdir -p ~/.local/share/fonts cd ~/.local/share/fonts 
curl -fLO "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf" 
curl -fLO "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf" 
curl -fLO "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf" 
curl -fLO "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf" 
fc-cache -fv

### Instalar `zsh-autosuggestions` (comando oficial del repo)
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

###Instalar `zsh-syntax-highlighting` (opcional pero recomendado)
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

###### Activar ambos en tu `~/.zshrc, Busca la línea `plugins=(...)` en tu `~/.zshrc` (por defecto suele decir `plugins=(git)`), y agrégalos:
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

### Aplica los cambios

exec zsh

setear zsh
chsh -s $(which zsh)

```

Instalar batcat, lsd y locate

``` bash
sudo apt install bat locate fzf lsd

#Solventar errores de fzf en la instalacion por apt, poner esto en .zshrc
#al final de todo
source <(fzf --zsh) 
zle -N fzf-file-widget 
bindkey '^T' fzf-file-widget
#luego ejecutar esto:
exec zsh

#alias para poner en la .zshrc
#cat
alias cat='batcat'
alias catn='batcat --style=plain'
alias catnp='batcat --style=plain --paging=never'

# ls
alias ll='lsd -lh --group-dirs=first'
alias la='lsd -a --group-dirs=first'
alias l='lsd --group-dirs=first'
alias lla='lsd -lha --group-dirs=first'
alias ls='lsd --group-dirs=first'

```

Fixes de algunas aplicaciones de Java que se descuadran

``` bash
#En la .zshrc poner eston
#Fix Java Problems
export _JAVA_AWT_WM_NONREPARENTING=1
#En bspwm poner esto
wmname LG3D &
```

Instalar # i3lock-fancy para el bloqueo de pantalla

``` bash
sudo apt install i3lock-fancy xss-lock 
```

configurar el comportamiento de suspender al cerrar la tapa del portatil:

``` bash
#EN
sudo nano /etc/systemd/logind.conf
#descomentar lo siguiente
HandleLidSwitch=suspend
HandleLidSwitchExternalPower=suspend
HandleLidSwitchDocked=ignore
LidSwitchIgnoreInhibited=yes
```
Configuraciones para que se suspenda el portatil al cerrar la tapa, aplica a mi hardware cambiar los valores segun sea necesario:
``` bash
sudo nano /etc/udev/rules.d/90-yoga-suspend.rules

#Pegar dentro:
ACTION=="add", SUBSYSTEM=="pci", ATTR{device}=="0x0000:00:14.0", ATTR{power/wakeup}="disabled"
ACTION=="add", SUBSYSTEM=="pci", ATTR{device}=="0x0000:00:1c.0", ATTR{power/wakeup}="disabled"
ACTION=="add", SUBSYSTEM=="pci", ATTR{device}=="0x0000:00:1c.2", ATTR{power/wakeup}="disabled"

#Tener descargado xss-lock y i3lock-fancy, colocar esta linea en el bspwmrc:
xss-lock --transfer-sleep-lock -- i3lock-fancy &
```
