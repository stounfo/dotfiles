{ ... }:

let
  systems = import ../../lib/systems.nix;
in
{
  description = "Google Chrome";

  systems = [
    systems.aarch64Linux
    systems.x86_64Linux
    systems.aarch64Darwin
    systems.x86_64Darwin
  ];

  home = ./home.nix;
}
