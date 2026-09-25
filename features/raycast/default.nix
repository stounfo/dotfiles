_:

let
  systems = import ../../lib/systems.nix;
in
{
  description = "Raycast";

  systems = [
    systems.aarch64Darwin
  ];

  darwin = ./darwin.nix;
}
