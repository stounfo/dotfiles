{ ... }:

let
  systems = import ../../lib/systems.nix;
in
{
  description = "Git";

  systems = [
    systems.aarch64Linux
    systems.x86_64Linux
    systems.aarch64Darwin
  ];

  featureDependencies = [ "delta" ];

  home = ./home.nix;
}
