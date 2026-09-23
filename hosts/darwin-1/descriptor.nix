let
  systems = import ../../lib/systems.nix;
in
{
  system = systems.aarch64Darwin;
  systemType = "darwin";
  systemName = "darwin-1";
  user = {
    name = "stounfo";
    home = "/Users/stounfo";
  };
  repoRoot = "/Users/stounfo/Desktop/dots";
  systemStateVersion = 6;
  homeStateVersion = "26.05";
}
