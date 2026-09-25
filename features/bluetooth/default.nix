_:

let
  systems = import ../../lib/systems.nix;
in
{
  description = "Bluetooth tools";

  systems = [
    systems.aarch64Linux
    systems.x86_64Linux
  ];

  home = ./home.nix;
  nixos = ./nixos.nix;
}
