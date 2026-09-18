{ ... }:

{
  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  users.users.stounfo.home = "/Users/stounfo";
  system.primaryUser = "stounfo";

  programs.zsh.enable = true;

  system.stateVersion = 6;
}
