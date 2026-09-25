_:

let
  systems = import ../../lib/systems.nix;
in
{
  description = "ChatGPT desktop";

  systems = [
    systems.aarch64Darwin
    systems.x86_64Darwin
  ];

  darwin = ./darwin.nix;
}
