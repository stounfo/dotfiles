{ config, lib, pkgs, ... }:

let
  cloneUrl = "git@github.com:stounfo/nvim.git";
  configDir = "${config.home.homeDirectory}/.config/nvim";
in
{
  programs.neovim.enable = true;

  home.activation.cloneNvimConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -e "${configDir}" ]; then
      $DRY_RUN_CMD ${pkgs.git}/bin/git clone \
        "${cloneUrl}" \
        "${configDir}"
    fi
  '';
}
