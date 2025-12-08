#!/usr/bin/env bash

# Caminho da logo (gerada pelo home-manager)
LOGO_FILE="$HOME/.config/fastfetch/logo.txt"

# Cores do seu tema (baseadas no colors.nix)
# a6e3a1 = Verde (Accent)
# cdd6f4 = Texto
# 1e1e2e = Fundo (mas o TTE vai limpar o fundo)

# Lista de efeitos legais para screensaver
EFFECTS=("beams" "spotlights" "rain" "print" "burn" "colorshift" "laseretch"  "unstable")

while true; do
    # Escolhe um efeito aleatório
    EFFECT=${EFFECTS[$RANDOM % ${#EFFECTS}]}
    
    clear
    
    # Executa o efeito
    # --no-color mantem as cores originais do arquivo se existirem, 
    # mas como sua logo é texto puro, vamos colorir com degradê do seu tema.
    cat "$LOGO_FILE" | tte --anchor-canvas c --anchor-text c "$EFFECT" \
        --final-gradient-stops a6e3a1 cdd6f4 \
        --final-gradient-steps 12 
        
    # Espera 1 segundo antes de reiniciar a animação
    sleep 1
done