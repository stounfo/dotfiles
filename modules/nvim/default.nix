{
  config,
  lib,
  pkgs,
  ...
}:

let
  cloneUrl = "https://github.com/stounfo/nvim.git";
  originUrl = "git@github.com:stounfo/nvim.git";
  configDir = "${config.home.homeDirectory}/.config/nvim";
in
{
  home.packages = with pkgs; [
    neovim
    gcc
    gnumake
    python3
    ripgrep
  ];

  home.activation.cloneNvimConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -e "${configDir}" ] || [ -d "${configDir}" ] && [ -z "$(${pkgs.coreutils}/bin/ls -A "${configDir}")" ]; then
      $DRY_RUN_CMD ${pkgs.git}/bin/git clone \
        "${cloneUrl}" \
        "${configDir}"
    fi

    if [ -d "${configDir}/.git" ]; then
      $DRY_RUN_CMD ${pkgs.git}/bin/git \
        -C "${configDir}" \
        remote set-url origin "${originUrl}"
    fi
  '';
}
