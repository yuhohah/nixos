{ pkgs, inputs, ... }:

# agenix (Home Manager): decrypts ../../secrets/*.age at login into
# $XDG_RUNTIME_DIR/agenix/<name> using ~/.ssh/id_ed25519.
# Edit a secret:  cd ~/Configuration/nixos/secrets && agenix -e <name>.age
{
  imports = [ inputs.agenix.homeManagerModules.default ];

  home.packages = [
    inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  age.identityPaths = [ "/home/luan/.ssh/id_ed25519" ];

  age.secrets = {
    omniroute-api-key.file = ../../secrets/omniroute-api-key.age;
    omniroute-env.file = ../../secrets/omniroute-env.age;
  };

  systemd.user.services.agenix.Service.RemainAfterExit = true;
}
