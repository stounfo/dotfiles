{ inputs, ... }:

let
  systems = import ../../lib/systems.nix;
in
{
  description = "Zen Browser";

  systems = [
    systems.aarch64Linux
    systems.x86_64Linux
    systems.aarch64Darwin
  ];

  homeImports = [
    inputs.zen-browser.homeModules.twilight
  ];

  home = ./home.nix;
}
