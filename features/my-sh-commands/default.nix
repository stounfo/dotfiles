_:

let
  systems = import ../../lib/systems.nix;
in
{
  description = "Personal note commands";

  systems = [
    systems.aarch64Linux
    systems.x86_64Linux
    systems.aarch64Darwin
  ];

  home = ./home.nix;
}
