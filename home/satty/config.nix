{ config, pkgs, ... }:

{
  # ========================================
  # CONFIGURAÇÃO DO SATTY (EDITOR DE SCREENSHOT)
  # ========================================
  
  home.file.".config/satty/config.toml".text = ''
    [general]
    # Salvar automaticamente ao copiar
    save-after-copy = true
    
    # Sair automaticamente ao salvar
    early-exit = true
    
    # Diretório padrão de saída
    output-filename = "${config.home.homeDirectory}/Pictures/Screenshots/screenshot-%Y-%m-%d_%H-%M-%S.png"
    
    # Copiar para clipboard
    copy-command = "wl-copy"
    
    # Ferramenta padrão ao abrir
    init-tool = "brush"
    
    # Tipo de destaque padrão
    primary-highlighter = "block"
    
    [ui]
    # Fonte
    font-family = "JetBrainsMono Nerd Font Mono"
    
    # Tamanho da fonte
    font-size = 12
    
    # Mostrar barra de ferramentas
    show-toolbox = true
    
    # Tamanho inicial da janela (ajuste conforme seu monitor)
    # Para monitor 1920x1080, recomendo:
    default-width = 1200
    default-height = 800
    
    # Para monitor maior (2560x1440), use:
    # default-width = 1600
    # default-height = 1000
    
    # Para tela cheia, comente as linhas acima e use:
    # fullscreen = true
  '';
}