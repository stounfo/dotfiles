_:

let
  systems = import ../../lib/systems.nix;
in
{
  description = "Neovim";

  systems = [
    systems.aarch64Linux
    systems.x86_64Linux
    systems.aarch64Darwin
  ];

  featureDependencies = [
    "npm"
    "fzf"
    "git"
    "gcc"
    "base-cli"
    "python3"
    "ripgrep"
  ];

  home = ./home.nix;
}
