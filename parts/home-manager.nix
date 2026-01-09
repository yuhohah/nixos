{ inputs, ... }: {
  flake.nixosModules.home-manager = { config, pkgs, ... }: {
    imports = [
      inputs.home-manager.nixosModules.home-manager
    ];

    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.users.luan = { lib, ... }: {
      imports = [ ../home/home.nix ];
      home.homeDirectory = lib.mkForce "/home/luan";
    };
  };
}
