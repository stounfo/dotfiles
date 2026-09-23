{ ... }:

let
  systems = import ../../lib/systems.nix;
in
{
  description = "Node.js and npm";

  systems = [
    systems.aarch64Linux
    systems.x86_64Linux
    systems.aarch64Darwin
  ];

  home = ./home.nix;
}
