{
  config,
  pkgs,
  hostDescriptor,
  ...
}:

{
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  home.packages = with pkgs; [
    neovim
  ];

  xdg.configFile."nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${hostDescriptor.repoRoot}/features/nvim/files/nvim";
}
