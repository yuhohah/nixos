#!/usr/bin/env bash

WALLPAPER_DIR="$HOME/Pictures/wallpaper"

# Se passar um arquivo como argumento
if [ -n "$1" ]; then
    swww img "$1" \
        --transition-type wipe \
        --transition-duration 2
    exit 0
fi

# Senão, escolhe aleatório
WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" \) | shuf -n 1)

if [ -n "$WALLPAPER" ]; then
    swww img "$WALLPAPER" \
        --transition-type wipe \
        --transition-duration 2
    echo "Wallpaper changed to: $WALLPAPER"
else
    echo "No wallpaper found in $WALLPAPER_DIR"
fi