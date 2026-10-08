{
  description = "NixOS configuration with Hyprland and Home Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";
    in {
      nixosConfigurations = {
        # --- HOST 1: nixos-btw ---
        "nixos-btw" = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; hostName = "nixos-btw"; };
          modules = [
            ./hosts/nixos-btw/default.nix
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                backupFileExtension = "backup";
                extraSpecialArgs = { inherit inputs; };
                users.luan = import ./home/hosts/nixos-btw.nix;
              };
            }
          ];
        };

        # --- HOST 2: arrow  ---
        "arrow" = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; hostName = "arrow"; };
          modules = [
            ./hosts/arrow/default.nix
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                backupFileExtension = "backup";
                extraSpecialArgs = { inherit inputs; };
                users.luan = import ./home/hosts/arrow.nix;
              };
            }
          ];
        };
      };
    };
}
