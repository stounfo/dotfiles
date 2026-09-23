{ lib }:

{
  features,
  system,
  systemType,
  userName,
}:

{ config, ... }:

let
  isNixos = systemType == "nixos";
  isDarwin = systemType == "darwin";

  wrapFragmentAsModule = import ./wrap-fragment-as-module.nix {
    inherit lib;
  };

  validateFeatureDependencies = import ./validate-feature-dependencies.nix {
    inherit lib;
  };

  supportsSystem =
    feature:
    feature ? systems && builtins.isList feature.systems && builtins.elem system feature.systems;

  featureOptionModules = lib.filter (module: module != null) (
    lib.mapAttrsToList (_: feature: feature.options or null) features
  );

  systemModules = lib.filter (module: module != null) (
    lib.mapAttrsToList (
      name: feature:
      let
        fragment =
          if isNixos then
            feature.nixos or null
          else if isDarwin then
            feature.darwin or null
          else
            throw "Unknown system type: ${systemType}";
      in
      if !supportsSystem feature || fragment == null then
        null
      else
        wrapFragmentAsModule {
          inherit fragment;

          condition =
            { config, ... }:
            config.dots.features.${name}.enable;
        }
    ) features
  );

  homeModules = lib.filter (module: module != null) (
    lib.mapAttrsToList (
      name: feature:
      let
        fragment = feature.home or null;
      in
      if !supportsSystem feature || fragment == null then
        null
      else
        wrapFragmentAsModule {
          inherit fragment;

          condition =
            { osConfig, ... }:
            osConfig.dots.features.${name}.enable;
        }
    ) features
  );

  homeImports = lib.concatMap (
    feature: if supportsSystem feature then feature.homeImports or [ ] else [ ]
  ) (lib.attrValues features);

  systemImports = lib.concatMap (
    feature:
    if !supportsSystem feature then
      [ ]
    else if isNixos then
      feature.nixosImports or [ ]
    else if isDarwin then
      feature.darwinImports or [ ]
    else
      throw "Unknown system type: ${systemType}"
  ) (lib.attrValues features);

  descriptorAssertions = lib.concatMap (
    name:
    let
      feature = features.${name};
    in
    [
      {
        assertion = feature ? description;

        message = "Feature ${name} is missing required field `description`.";
      }

      {
        assertion = !(feature ? description) || builtins.isString feature.description;

        message = "Feature ${name} field `description` must be a string.";
      }

      {
        assertion = feature ? systems;

        message = "Feature ${name} is missing required field `systems`.";
      }

      {
        assertion = !(feature ? systems) || builtins.isList feature.systems;

        message = "Feature ${name} field `systems` must be a list.";
      }
    ]
  ) (lib.attrNames features);

  systemAssertions = lib.mapAttrsToList (name: feature: {
    assertion = !config.dots.features.${name}.enable || supportsSystem feature;

    message =
      let
        supportedSystems =
          if feature ? systems && builtins.isList feature.systems then
            lib.concatStringsSep ", " (map toString feature.systems)
          else
            "<invalid descriptor>";
      in
      ''
        Feature ${name} is not supported on ${system}.
        Supported systems: ${supportedSystems}.
      '';
  }) features;
in
{
  imports = [
    (validateFeatureDependencies {
      inherit features;
    })
  ]
  ++ featureOptionModules
  ++ systemImports
  ++ systemModules;

  options.dots.features = lib.mapAttrs (name: _: {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable feature ${name}.";
    };
  }) features;

  config = {
    assertions = descriptorAssertions ++ systemAssertions;

    home-manager.users.${userName}.imports = homeImports ++ homeModules;
  };
}
