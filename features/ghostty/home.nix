{
  config,
  pkgs,
  hostDescriptor,
  ...
}:

let
  files = "${hostDescriptor.repoRoot}/features/ghostty/files";
in
{
  home.packages = [
    (if pkgs.stdenv.hostPlatform.isDarwin then pkgs.ghostty-bin else pkgs.ghostty)
  ];

  xdg.configFile = {
    "ghostty/config.ghostty".source =
      config.lib.file.mkOutOfStoreSymlink "${files}/config.ghostty";

    "ghostty/${hostDescriptor.systemType}".source =
      config.lib.file.mkOutOfStoreSymlink "${files}/${hostDescriptor.systemType}";

    "ghostty/themes".source =
      config.lib.file.mkOutOfStoreSymlink "${files}/themes";
  };
}
