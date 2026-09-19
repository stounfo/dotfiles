{ lib, pkgs, ... }:

{
  home.packages = lib.optionals pkgs.stdenv.hostPlatform.isLinux [ pkgs.ghostty ];

  xdg.configFile."ghostty" = {
    source = ./files;
    recursive = true;
  };
}
