{
  description = "NixOS configuration with Hyprland and Home Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Secrets (API keys) encrypted with age — see ./secrets/secrets.nix
    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";
      mkHost = hostName: nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs hostName; };
        modules = [ ./hosts/${hostName} ];
      };
    in {
      devShells.${system}.default = import ./shell.nix {
        pkgs = nixpkgs.legacyPackages.${system};
      };

      nixosConfigurations = {
        "nixos-btw" = mkHost "nixos-btw";
        "arrow" = mkHost "arrow";
      };
    };
}
