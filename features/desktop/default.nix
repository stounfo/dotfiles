{ ... }:

let
  systems = import ../../lib/systems.nix;
in
{
  description = "Desktop";

  systems = [
    systems.aarch64Linux
    systems.x86_64Linux
  ];

  featureDependencies = [
    "ghostty"
  ];

  home = ./home.nix;
  nixos = ./nixos.nix;
}
