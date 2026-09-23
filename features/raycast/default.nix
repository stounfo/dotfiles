{ ... }:

let
  systems = import ../../lib/systems.nix;
in
{
  description = "Raycast";

  systems = [
    systems.aarch64Darwin
    systems.x86_64Darwin
  ];

  darwin = ./darwin.nix;
}
