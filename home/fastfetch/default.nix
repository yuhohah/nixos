{ config, pkgs, ... }:

{


home.file.".config/fastfetch/logo.txt".text = ''
 ██▓     █    ██  ▄▄▄       ███▄    █ 
▓██▒     ██  ▓██▒▒████▄     ██ ▀█   █ 
▒██░    ▓██  ▒██░▒██  ▀█▄  ▓██  ▀█ ██▒
▒██░    ▓▓█  ░██░░██▄▄▄▄██ ▓██▒  ▐▌██▒
░██████▒▒▒█████▓  ▓█   ▓██▒▒██░   ▓██░
░ ▒░▓  ░░▒▓▒ ▒ ▒  ▒▒   ▓▒█░░ ▒░   ▒ ▒ 
░ ░ ▒  ░░░▒░ ░ ░   ▒   ▒▒ ░░ ░░   ░ ▒░
  ░ ░    ░░░ ░ ░   ░   ▒      ░   ░ ░ 
    ░  ░   ░           ░  ░         ░ 
'';

programs.fastfetch = {
    enable = true;
    settings = {
      "$schema" = "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json";
      logo = {
        type = "file";
        source = "~/.config/fastfetch/logo.txt";
        color = {
          "1" = "green";
          "2" = "cyan";
        };
        padding = {
          top = 2;
          right = 6;
          left = 2;
        };
      };
      modules = [
        "break"
        {
          type = "custom";
          format = "┌──────────────────────Hardware──────────────────────┐";
        }
        {
          type = "host";
          key = " PC";
          keyColor = "green";
        }
        {
          type = "cpu";
          key = "│ ├";
          showPeCoreCount = true;
          keyColor = "green";
        }
        {
          type = "gpu";
          key = "│ ├";
          detectionMethod = "pci";
          keyColor = "green";
        }
        {
          type = "display";
          key = "│ ├󱄄";
          keyColor = "green";
        }
        {
          type = "disk";
          key = "│ ├󰋊";
          keyColor = "green";
        }
        {
          type = "memory";
          key = "│ ├";
          keyColor = "green";
        }
        {
          type = "swap";
          key = "└ └󰓡 ";
          keyColor = "green";
        }
        {
          type = "custom";
          format = "└────────────────────────────────────────────────────┘";
        }
        "break"
        {
          type = "custom";
          format = "┌──────────────────────Software──────────────────────┐";
        }
        {
          type = "os";
          key = " OS";
          keyColor = "blue";
        }
        {
          type = "kernel";
          key = "│ ├";
          keyColor = "blue";
        }
        {
          type = "wm";
          key = "│ ├";
          keyColor = "blue";
        }
        {
          type = "terminal";
          key = "│ ├";
          keyColor = "blue";
        }
        {
          type = "shell";
          key = "│ ├";
          keyColor = "blue";
        }
        {
          type = "packages";
          key = "│ ├󰏖";
          keyColor = "blue";
        }
        {
          type = "wmtheme";
          key = "│ ├󰉼";
          keyColor = "blue";
        }
        {
          type = "icons";
          key = "│ ├󰀻";
          keyColor = "blue";
        }
        {
          type = "terminalfont";
          key = "└ └";
          keyColor = "blue";
        }
        {
          type = "custom";
          format = "└────────────────────────────────────────────────────┘";
        }
        "break"
        {
          type = "custom";
          format = "┌────────────────────Uptime / Age────────────────────┐";
        }
        {
          type = "command";
          key = "󱦟 OS Age";
          keyColor = "magenta";
          text = "birth_install=$(stat -c %W /); current=$(date +%s); time_progression=$((current - birth_install)); days_difference=$((time_progression / 86400)); echo $days_difference days";
        }
        {
          type = "uptime";
          key = "󱫐 Uptime";
          keyColor = "magenta";
        }
        {
          type = "custom";
          format = "└────────────────────────────────────────────────────┘";
        }
        "break"
        {
          type = "colors";
          symbol = "circle";
        }
      ];
    };
  };  
}