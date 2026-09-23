{
  pkgs,
  config,
  hostDescriptor,
  ...
}:

{
  home.packages = [ pkgs.bat ];

  xdg.configFile."bat/config".source =
    config.lib.file.mkOutOfStoreSymlink "${hostDescriptor.repoRoot}/features/bat/files/config";
}
