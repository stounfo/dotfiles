{
  lib,
  inputs,
}:

let
  mkFeatureModules = import ./mk-feature-modules.nix {
    inherit lib;
  };
in

{
  features,
  hostDescriptor,
  hostModule,
}:

let
  isNixos = hostDescriptor.systemType == "nixos";
  isDarwin = hostDescriptor.systemType == "darwin";

  homeManagerModule =
    if isNixos then
      inputs.home-manager.nixosModules.home-manager
    else if isDarwin then
      inputs.home-manager.darwinModules.home-manager
    else
      throw "Unknown system type: ${hostDescriptor.systemType}";

  systemModule =
    if isNixos then
      ../system/nixos.nix
    else if isDarwin then
      ../system/darwin.nix
    else
      throw "Unknown system type: ${hostDescriptor.systemType}";
in
{
  imports = [
    homeManagerModule

    systemModule

    (mkFeatureModules {
      inherit features;

      inherit (hostDescriptor) system;
      inherit (hostDescriptor) systemType;
      userName = hostDescriptor.user.name;
    })

    hostModule
  ];

  nixpkgs.hostPlatform = hostDescriptor.system;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    extraSpecialArgs = {
      inherit hostDescriptor inputs;
    };

    users.${hostDescriptor.user.name}.imports = [
      ../system/home.nix
    ];
  };
}
