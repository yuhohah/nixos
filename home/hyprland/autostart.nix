{ ... }:

{
  wayland.windowManager.hyprland.settings = {
    exec-once = [
      "swww init"
      "vicinae server"
      #"${pkgs.numlockx}/bin/numlockx on"
      # "wofi --show drun"  # ← NÃO FAÇA ISSO (abre na inicialização!)
    ];
  };
}