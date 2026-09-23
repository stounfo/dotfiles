{ pkgs, ... }:

{
  home.packages = [
    pkgs.rustc
    pkgs.cargo
    pkgs.rustfmt
    pkgs.clippy
  ];
}
