{
  description = "NixOS configuration with Hyprland and Home Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    vicinae.url = "github:vicinaehq/vicinae";
  };

  

  outputs = { nixpkgs, nixpkgs-unstable, home-manager, vicinae, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
      unstable = import nixpkgs-unstable { inherit system; config.allowUnfree = true; }; 
    in {
      # --- HOST 1: nixos-btw ---
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
    

    # --- HOST 2: arrow  ---
      nixosConfigurations."arrow" = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          # Apontar para o novo arquivo de config principal
          ./arrow.nix

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.luan = { lib, ...}: {
              # Você pode usar o mesmo home.nix se as configs do usuário
              # forem iguais, ou criar um novo (ex: ./home/home-arrow.nix)
              imports = [ ./home/home.nix ]; 
              home.homeDirectory = lib.mkForce "/home/luan";
            };
          }
        ];
        specialArgs = { inherit unstable; };
      };
    };
}

