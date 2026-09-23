{ pkgs, lib, ... }:

{
  home.packages = lib.optionals pkgs.stdenv.hostPlatform.isLinux [ pkgs.tableplus ];
}
