{
  lib,
  inputs,
  features,
}:

hosts:

let
  mkHost = import ./mk-host.nix {
    inherit lib inputs;
  };

  mkConfiguration =
    name: hostDir:

    let
      hostDescriptor = import (hostDir + "/descriptor.nix");

      configurationArgs = {
        specialArgs = {
          inherit hostDescriptor inputs;
        };

        modules = [
          (mkHost {
            inherit features hostDescriptor;

            hostModule = hostDir;
          })
        ];
      };
    in

    if hostDescriptor.systemType == "nixos" then
      {
        nixosConfigurations.${name} = inputs.nixpkgs.lib.nixosSystem configurationArgs;
      }
    else if hostDescriptor.systemType == "darwin" then
      {
        darwinConfigurations.${name} =
          inputs.nix-darwin.lib.darwinSystem configurationArgs;
      }
    else
      throw "Unknown system type: ${hostDescriptor.systemType}";

in

lib.foldl' (
  result: name: lib.recursiveUpdate result (mkConfiguration name hosts.${name})
) { } (lib.attrNames hosts)
