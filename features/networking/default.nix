_:

let
  systems = import ../../lib/systems.nix;
in
{
  description = "Networking";

  systems = [
    systems.aarch64Linux
    systems.x86_64Linux
  ];

  nixos = ./nixos.nix;
}
