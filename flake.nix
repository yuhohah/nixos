{
  description = "NixOS configuration with Hyprland and Home Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    vicinae.url = "github:vicinaehq/vicinae";
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";
      unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    in {
      nixosConfigurations = {
        # --- HOST 1: nixos-btw ---
        "nixos-btw" = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs unstable; hostName = "nixos-btw";};
          modules = [
            ./hosts/nixos-btw/default.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs unstable; };
              home-manager.users.luan = import ./home/hosts/nixos-btw.nix;
            }
          ];
        };

        # --- HOST 2: arrow  ---
        "arrow" = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs unstable; hostName = "arrow";};
          modules = [
            ./hosts/arrow/default.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs unstable; };
              home-manager.users.luan = import ./home/hosts/arrow.nix;
            }
          ];
        };
      };
    };
}

