{ hostDescriptor, ... }:

{
  system.primaryUser = hostDescriptor.user.name;
  system.stateVersion = hostDescriptor.systemStateVersion;

  users.users.${hostDescriptor.user.name}.home = hostDescriptor.user.home;

  nixpkgs.config.allowUnfree = true;

  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = false;
      upgrade = true;
      cleanup = "uninstall";
    };

    greedyCasks = true;
  };
}
