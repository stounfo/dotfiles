_:

let
  systems = import ../../lib/systems.nix;
in
{
  description = "Nerd Fonts";

  systems = [
    systems.aarch64Linux
    systems.x86_64Linux
    systems.aarch64Darwin
  ];

  nixos = ./system.nix;
  darwin = ./system.nix;
}
