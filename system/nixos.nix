{ hostDescriptor, ... }:

{
  system.stateVersion = hostDescriptor.systemStateVersion;

  users.users.${hostDescriptor.user.name} = {
    isNormalUser = true;
    home = hostDescriptor.user.home;
    extraGroups = [
      "wheel"
    ];
  };

  nixpkgs.config.allowUnfree = true;
}
