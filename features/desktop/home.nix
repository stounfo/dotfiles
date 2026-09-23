{
  config,
  pkgs,
  hostDescriptor,
  ...
}:

{
  home.packages = [
    pkgs.noctalia
    pkgs.bibata-cursors
    pkgs.elephant
    pkgs.walker
  ];

  xdg.configFile."hypr".source =
    config.lib.file.mkOutOfStoreSymlink "${hostDescriptor.repoRoot}/features/desktop/files/hypr";
}
