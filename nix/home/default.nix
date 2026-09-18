{ username, ... }:

{
  imports = [ ../modules/nvim.nix ];

  home.username = username;
  home.homeDirectory = "/Users/${username}";
  home.stateVersion = "26.05";
}
