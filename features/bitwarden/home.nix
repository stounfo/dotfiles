{
  config,
  pkgs,
  hostDescriptor,
  ...
}:

{
  home.packages = [
    pkgs.bitwarden-desktop
  ];
}
