{ hostDescriptor, ... }:

{
  networking = {
    hostName = hostDescriptor.systemName;
    networkmanager.enable = true;
  };
  users.users.${hostDescriptor.user.name}.extraGroups = [
    "networkmanager"
  ];
}
