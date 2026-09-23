{ config, hostDescriptor, ... }:

{
  programs.starship = {
    enable = true;
    enableZshIntegration = false;
  };
  xdg.configFile."starship.toml".source =
    config.lib.file.mkOutOfStoreSymlink "${hostDescriptor.repoRoot}/features/starship/files/starship.toml";
}
