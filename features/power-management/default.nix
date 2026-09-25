_:

let
  systems = import ../../lib/systems.nix;
in
{
  description = "Power management";

  systems = [
    systems.aarch64Linux
    systems.x86_64Linux
  ];

  nixos = ./nixos.nix;
}
