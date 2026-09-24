{
  config,
  pkgs,
  hostDescriptor,
  ...
}:

{
  home.packages = [
    pkgs.bitwarden-desktop
    pkgs.bitwarden-cli
  ];

  home.sessionVariables = {
    SSH_AUTH_SOCK = "$HOME/.bitwarden-ssh-agent.sock";
  };
}
