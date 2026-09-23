{ pkgs, hostDescriptor, ... }:

{
  programs.zsh.enable = true;
  users.users.${hostDescriptor.user.name}.shell = pkgs.zsh;
}
