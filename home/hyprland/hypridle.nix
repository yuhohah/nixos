{ config, pkgs, osConfig, lib, ... }:


let
  hostname = osConfig.networking.hostName;

  arrow = {
    listener = [
      {
        ignore_inhibit = true;
        timeout = 150; 
        on-timeout = "brightnessctl set 10% && hyprctl keyword cursor:inactive_timeout 0.1 && ~/.local/bin/run-screensaver";
        on-resume = "brightnessctl set 60% && hyprctl keyword cursor:inactive_timeout 0 && pkill -f 'alacritty.*screensaver'";
      }
      {
        timeout = 480;  
        on-timeout = "hyprctl dispatch dpms off && loginctl lock-session";
        on-resume = "hyprctl dispatch dpms on";
      }
      {
        timeout = 900;  
        on-timeout = "systemctl suspend";
      }
    ];
  };

  nixos-btw = {
    listener = [
      {
        ignore_inhibit = true;
        timeout = 600;
        on-timeout = "hyprctl keyword cursor:inactive_timeout 0.1 && ~/.local/bin/run-screensaver";
        on-resume = "hyprctl keyword cursor:inactive_timeout 0 && pkill -f 'alacritty.*screensaver'";
      }
      {
        timeout = 900;
        on-timeout = "hyprctl dispatch dpms off && loginctl lock-session";
        on-resume = "hyprctl dispatch dpms on";
      }
      {
        timeout = 1200;
        on-timeout = "systemctl suspend";
      }
    ];
  };

  # Seleciona a config baseada no hostname
  listenerConfig = if hostname == "arrow" then arrow else nixos-btw;
  
in
{
  services.hypridle = {
    enable = true;
    
    settings = {
      general = {
        # Tempo antes de travar (em segundos)
        lock_cmd = "pidof hyprlock || hyprlock";  # Evita múltiplas instâncias
        before_sleep_cmd = "loginctl lock-session";  # Trava antes de suspender
        after_sleep_cmd = "hyprctl dispatch dpms on";  # Liga tela após acordar
      };

      # Listeners - Ações baseadas em tempo de inatividade
      listener = listenerConfig.listener;
    };
  };

}