{ config, pkgs, ... }:

{
  # ========================================
  # CONFIGURAÇÃO DO LOGIND
  # Gerencia eventos de energia do notebook
  # ========================================
  
  services.logind = {
    # Ações ao fechar a tampa do notebook
    lidSwitch = "suspend";          # suspende ao fechar
    # Outras opções:
    # "ignore" = não faz nada
    # "poweroff" = desliga
    # "hibernate" = hiberna
    # "lock" = apenas bloqueia
    
    # Ação ao fechar tampa com carregador conectado
    lidSwitchDocked = "ignore";     # não faz nada quando conectado
    
    # Ação ao fechar tampa com monitor externo
    lidSwitchExternalPower = "ignore";
    
    # Ação ao pressionar botão power
    powerKey = "suspend";           # suspende ao pressionar power
    # Outras opções: "poweroff", "ignore", "hibernate", "lock"
    
    # Ação ao pressionar botão suspend (se existir)
    suspendKey = "suspend";
    
    # Ação ao pressionar botão hibernate (se existir)
    hibernateKey = "hibernate";
    
    # Configurações extras
    extraConfig = ''
      # Tempo antes de suspender quando inativo (0 = desabilitado)
      #idleAction = "suspend";
      #idleActionSec = "30min";        # Suspende após 30min de inatividade
      
      # Tempo de espera antes de aplicar ação de inatividade
      HoldoffTimeoutSec=30s
      
      # Tempo máximo de inatividade antes de ação forçada
      RuntimeDirectorySize=10%
      
      # Permitir que usuários suspendam sem senha
      HandleLidSwitchDocked=ignore
    '';
  };

  # ========================================
  # CONFIGURAÇÃO DE SUSPENSÃO
  # ========================================
  
  systemd.sleep.extraConfig = ''
    # Permitir suspensão
    AllowSuspend=yes
    
    # Permitir hibernação (requer swap configurado)
    AllowHibernation=yes
    
    # Suspender e depois hibernar
    AllowSuspendThenHibernate=yes
    
    # Hybrid sleep (suspende na RAM e disco)
    AllowHybridSleep=yes
    
    # Tempo para hibernar após suspender (2 horas)
    HibernateDelaySec=2h
  '';

  # ========================================
  # HOOKS PARA SUSPENSÃO/HIBERNAÇÃO
  # ========================================
  
  # Script executado ANTES de suspender/hibernar
  systemd.services.pre-suspend = {
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
  systemd.services.post-resume = {
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