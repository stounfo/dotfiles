_:

let
  systems = import ../../lib/systems.nix;
in
{
  description = "Zsh shell";

  systems = [
    systems.aarch64Linux
    systems.x86_64Linux
    systems.aarch64Darwin
  ];

  featureDependencies = [
    "curlie"
    "my-sh-commands"
    "starship"
    "zoxide"
    "fzf"
    "lsd"
    "bat"
    "nvim"
    "git"
  ];

  nixos = ./nixos.nix;
  darwin = ./darwin.nix;

  home = ./home.nix;
}
