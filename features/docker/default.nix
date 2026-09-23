{ ... }:

let
  systems = import ../../lib/systems.nix;
in
{
  description = "Docker containers";

  systems = [
    systems.aarch64Linux
    systems.x86_64Linux
    systems.aarch64Darwin
  ];

  nixos = ./nixos.nix;
  darwin = ./darwin.nix;
}
