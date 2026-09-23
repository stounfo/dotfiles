{
  description = "Cross-platform Nix configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-apple-silicon = {
      url = "github:nix-community/nixos-apple-silicon";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";

      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      ...
    }:
    let
      inherit (nixpkgs) lib;

      features = import ./features {
        inherit inputs;
      };

      mkConfigurations = import ./lib/mk-configurations.nix {
        inherit lib inputs features;
      };
    in

    mkConfigurations {
      darwin-1 = ./hosts/darwin-1;
      nixos-1 = ./hosts/nixos-1;
    };
}
