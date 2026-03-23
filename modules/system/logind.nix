{ config, pkgs, ... }:

{
  # ========================================
  # CONFIGURAÇÃO DO LOGIND
  # Gerencia eventos de energia do notebook
  # ========================================
  
  services.logind = {
    # Ações de energia foram movidas para 'settings'
    
    # Configurações extras
    settings = {
      Login = {
        # Ações de energia integradas
        HandleLidSwitch = "suspend";
        HandleLidSwitchDocked = "ignore";
        HandleLidSwitchExternalPower = "ignore";
        HandlePowerKey = "suspend";

        # Tempo de espera antes de aplicar ação de inatividade
        HoldoffTimeoutSec = "30s";
        
        # Tempo máximo de inatividade antes de ação forçada
        RuntimeDirectorySize = "10%";
      };
    };
  };

  # ========================================
  # CONFIGURAÇÃO DE SUSPENSÃO
  # ========================================
  
  systemd.sleep.settings = {
    Sleep = {
      # Permitir suspensão
      AllowSuspend = "yes";
      
      # Permitir hibernação (requer swap configurado)
      AllowHibernation = "yes";
      
      # Suspender e depois hibernar
      AllowSuspendThenHibernate = "yes";
      
      # Hybrid sleep (suspende na RAM e disco)
      AllowHybridSleep = "yes";
      
      # Tempo para hibernar após suspender (2 horas)
      HibernateDelaySec = "2h";
    };
  };

  # ========================================
  # HOOKS PARA SUSPENSÃO/HIBERNAÇÃO
  # ========================================
  
  # Script executado ANTES de suspender/hibernar
  systemd.services.custom-pre-suspend = {
    description = "Pre-suspend tasks";
    wantedBy = [ "sleep.target" ];
    before = [ "sleep.target" ];
    script = ''
      # Sincroniza dados em disco
      ${pkgs.coreutils}/bin/sync
      
      # Para serviços problemáticos (exemplo)
      # systemctl stop problematic-service.service
    '';
    serviceConfig.Type = "oneshot";
  };

  # Script executado DEPOIS de acordar
  systemd.services.custom-post-resume = {
    description = "Post-resume tasks";
    wantedBy = [ "suspend.target" "hibernate.target" ];
    after = [ "suspend.target" "hibernate.target" ];
    script = ''
      # Religa Wi-Fi se necessário
      ${pkgs.networkmanager}/bin/nmcli radio wifi on
      
      # Religa Bluetooth
      ${pkgs.bluez}/bin/bluetoothctl power on
      
      # Atualiza relógio do sistema
      ${pkgs.systemd}/bin/hwclock --hctosys
    '';
    serviceConfig.Type = "oneshot";
  };
}