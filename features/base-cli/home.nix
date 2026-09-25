{ pkgs, ... }:

{
  home.packages = with pkgs; [
    tree
    unzip
    zip
    fastfetch
    gnumake
  ];
}
