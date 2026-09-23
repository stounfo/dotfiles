let
  systems = import ../../lib/systems.nix;
in
{
  system = systems.aarch64Linux;
  systemType = "nixos";
  systemName = "nixos-1";
  user = {
    name = "stounfo";
    home = "/home/stounfo";
  };
  repoRoot = "/home/stounfo/Projects/dot";
  systemStateVersion = "26.11";
  homeStateVersion = "26.05";
}
