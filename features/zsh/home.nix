{
  config,
  pkgs,
  hostDescriptor,
  ...
}:

{
  xdg.configFile."zsh/config.zsh".source =
    config.lib.file.mkOutOfStoreSymlink "${hostDescriptor.repoRoot}/features/zsh/files/.zshrc";

  xdg.dataFile = {
    "zsh/plugins/fzf-tab".source = "${pkgs.zsh-fzf-tab}/share/fzf-tab";

    "zsh/plugins/zsh-autosuggestions".source =
      "${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions";

    "zsh/plugins/zsh-vi-mode".source = "${pkgs.zsh-vi-mode}/share/zsh-vi-mode";

    "zsh/plugins/zsh-syntax-highlighting".source =
      "${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting";

    "zsh/plugins/zsh-you-should-use/zsh-you-should-use.plugin.zsh".source =
      "${pkgs.zsh-you-should-use}/share/zsh/plugins/you-should-use/you-should-use.plugin.zsh";
  };

  programs.zsh = {
    enable = true;
    enableCompletion = false;

    initContent = ''
      source "${config.xdg.configHome}/zsh/config.zsh"
    '';
  };
}
