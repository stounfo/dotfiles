_:

let
  systems = import ../../lib/systems.nix;
in
{
  description = "TablePlus";

  systems = [
    systems.aarch64Linux
    systems.x86_64Linux
    systems.aarch64Darwin
    systems.x86_64Darwin
  ];

  home = ./home.nix;
  darwin = ./darwin.nix;
}
