{
  pkgs,
  config,
  hostDescriptor,
  ...
}:

{
  home.packages = [ pkgs.ripgrep ];

  xdg.configFile.".ripgreprc".source =
    config.lib.file.mkOutOfStoreSymlink "${hostDescriptor.repoRoot}/features/ripgrep/files/.ripgreprc";

  home.sessionVariables.RIPGREP_CONFIG_PATH = "${config.xdg.configHome}/.ripgreprc";
}
