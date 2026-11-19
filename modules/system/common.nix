{ config, lib, pkgs, ... }:

{
  imports = [
    ./networking.nix
    ./audio.nix
    ./hyprland.nix
    ./greetd.nix
    ./users.nix
    ./gvfs.nix
    ./tracker.nix
    ./home-manager.nix
    ../roles/default.nix
  ];
  
  options.my.system.core.enable = lib.mkEnableOption "Core System Config";

  config = lib.mkIf config.my.system.core.enable {
    boot.loader = {
      systemd-boot = {
        enable = true;
        graceful = true; # Don't fail if EFI NVRAM is full (no space for new boot entry)
      };
      efi.canTouchEfiVariables = true;
    };

    services.resolved = {
      enable = true;
      # Evita conflito na porta 5353 com o avahi-daemon
      settings.Resolve.MulticastDNS = false;
    };
    services.fstrim.enable = true;

    fileSystems."/".options = [ "noatime" ];

    zramSwap = {
      enable = true;
      memoryPercent = 50;
    };

    # Tuning de memória para ZRAM (latência zero, evita readahead de 8 páginas e stutter de kswapd)
    boot.kernel.sysctl = {
      "vm.page-cluster" = 0;
      "vm.swappiness" = 100;
      "vm.watermark_boost_factor" = 0;
      "vm.watermark_scale_factor" = 125;
    };

    nix.settings = {
      experimental-features = [ "nix-command" "flakes" ];
      accept-flake-config = true;
      auto-optimise-store = true;
    };
    
    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    boot.supportedFilesystems = [ "ntfs" "vfat" "exfat" ];
      
    environment.localBinInPath = true;

    # Compatibilidade SSL para binários e embedded runtimes (ex: antigravity-acp, python urllib)
    environment.etc."ssl/cert.pem".source = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";

    nixpkgs.config.allowUnfree = true;
    system.stateVersion = "25.05"; # Retirado do common anterior

    time.timeZone = "America/Sao_Paulo";

    i18n = {
      defaultLocale = "pt_BR.UTF-8";
      extraLocaleSettings = {
        LC_TIME = "pt_BR.UTF-8";
        LC_MONETARY = "pt_BR.UTF-8";
        LC_NUMERIC = "pt_BR.UTF-8";
        LC_MEASUREMENT = "pt_BR.UTF-8";
      };
    };

    fonts.packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      nerd-fonts.ubuntu
      font-awesome
      material-design-icons
      noto-fonts
      noto-fonts-color-emoji
    ];

    fonts.fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [ "JetBrainsMono Nerd Font Mono" "Noto Color Emoji" ];
        sansSerif = [ "Ubuntu Nerd Font" "Noto Color Emoji" ];
        serif = [ "Noto Serif" "Noto Color Emoji" ];
      };
    };
  };
}
