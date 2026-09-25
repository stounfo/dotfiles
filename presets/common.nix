{ lib, ... }:

{
  dots.features = {
    fonts.enable = lib.mkDefault true;
    telegram.enable = lib.mkDefault true;
    tableplus.enable = lib.mkDefault true;
    docker.enable = lib.mkDefault true;
    curlie.enable = lib.mkDefault true;
    my-sh-commands.enable = lib.mkDefault true;
    kubectl.enable = lib.mkDefault true;
    helm.enable = lib.mkDefault true;
    k9s.enable = lib.mkDefault true;
    uv.enable = lib.mkDefault true;
    go.enable = lib.mkDefault true;
    rust.enable = lib.mkDefault true;
    usql.enable = lib.mkDefault true;
    editorconfig.enable = lib.mkDefault true;
    jless.enable = lib.mkDefault true;
    htop.enable = lib.mkDefault true;
    base-cli.enable = lib.mkDefault true;
    cloc.enable = lib.mkDefault true;
    zsh.enable = lib.mkDefault true;
    starship.enable = lib.mkDefault true;
    zoxide.enable = lib.mkDefault true;
    fzf.enable = lib.mkDefault true;
    bat.enable = lib.mkDefault true;
    lsd.enable = lib.mkDefault true;
    delta.enable = lib.mkDefault true;
    gh.enable = lib.mkDefault true;
    npm.enable = lib.mkDefault true;
    zen-browser.enable = lib.mkDefault true;
    codex.enable = lib.mkDefault true;
    ghostty.enable = lib.mkDefault true;
    git.enable = lib.mkDefault true;
    nvim.enable = lib.mkDefault true;
    gcc.enable = lib.mkDefault true;
    python3.enable = lib.mkDefault true;
    ripgrep.enable = lib.mkDefault true;
    ssh.enable = lib.mkDefault true;
    vim.enable = lib.mkDefault true;
    antigravity-cli.enable = lib.mkDefault true;
    google-chrome.enable = lib.mkDefault true;
    bitwarden.enable = lib.mkDefault true;
  };
}
