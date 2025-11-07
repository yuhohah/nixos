{
  description = "NixOS configuration with Hyprland and Home Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    vicinae.url = "github:vicinaehq/vicinae";
  };

  

  outputs = { nixpkgs, nixpkgs-unstable, home-manager, vicinae, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
      unstable = import nixpkgs-unstable { inherit system; config.allowUnfree = true; }; 
    in {
      nixosConfigurations."nixos-btw" = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./configuration.nix
        
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.luan = { lib, ...}: {
              imports = [ ./home/home.nix];
              home.homeDirectory = lib.mkForce "/home/luan";
            };
          }
        ];
        specialArgs = { inherit unstable; };
      };
    };
}

