#!/usr/bin/env bash
# Lança o Alacritty apontando para o config de screensaver e rodando o script de animação
alacritty --config-file ~/.config/alacritty/screensaver.toml -e ~/.local/bin/term-saver
