{ hostDescriptor, ... }:

{
  home.stateVersion = hostDescriptor.homeStateVersion;

  xdg.enable = true;
}
