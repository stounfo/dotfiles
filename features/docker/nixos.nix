{ hostDescriptor, ... }:

{
  virtualisation.docker.enable = true;

  users.users.${hostDescriptor.user.name}.extraGroups = [
    "docker"
  ];
}
