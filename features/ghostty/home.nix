{
  config,
  pkgs,
  hostDescriptor,
  ...
}:

{
  home.packages = [
    (if pkgs.stdenv.hostPlatform.isDarwin then pkgs.ghostty-bin else pkgs.ghostty)
  ];

  xdg.configFile."ghostty/config.ghostty".source =
    config.lib.file.mkOutOfStoreSymlink
      "${hostDescriptor.repoRoot}/features/ghostty/files/${hostDescriptor.systemType}/config.ghostty";

  xdg.configFile."ghostty/themes".source =
    config.lib.file.mkOutOfStoreSymlink "${hostDescriptor.repoRoot}/features/ghostty/files/themes";
}
