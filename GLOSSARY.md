# NixOS Desktop Environment

Arquitetura e termos de domínio para a configuração do sistema NixOS com Hyprland e Quickshell.

## Language

**Desktop Shell**:
O subsistema de interface gráfica implementado em Quickshell/QML, responsável pela barra de status, notificações e widgets de controle.
_Avoid_: Window manager, interface de usuário genérica

**Agent Usage Tracker**:
O coletor de métricas que monitora o consumo de tokens e a cota diária do assistente a partir dos transcripts de sessões e atualiza o estado do widget na barra.
_Avoid_: Gemini CLI, AI chat script

**Desktop Helper**:
Script utilitário interno acionado por painéis ou widgets do Desktop Shell, operando nos limites do runtime gráfico.
_Avoid_: Global CLI script, system package

**Window Manager Configuration**:
O subsistema de gerenciamento de janelas implementado em módulos Lua nativos, responsável pelas regras de composição, tiling, monitores, atalhos de teclado e autostart do Hyprland.
_Avoid_: Hyprland config strings, extraConfig template
