{
  pkgs,
  config,
  hostDescriptor,
  ...
}:

{
  home.packages = [ pkgs.fzf ];

  xdg.configFile."fzf/fzf.zsh".source =
    config.lib.file.mkOutOfStoreSymlink "${hostDescriptor.repoRoot}/features/fzf/files/fzf.zsh";
}
