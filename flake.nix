{
  description = "NixOS and macOS configuration with Home Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, home-manager, nix-darwin, ... }:
    let
      homeManagerConfig = {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          users.stounfo = import ./home;
        };
      };
    in
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";

        modules = [
          ./hosts/nixos
          home-manager.nixosModules.home-manager

          homeManagerConfig
        ];
      };

      darwinConfigurations.macbook = nix-darwin.lib.darwinSystem {
        modules = [
          ./hosts/macbook
          home-manager.darwinModules.home-manager

          homeManagerConfig
        ];
      };
    };
}
