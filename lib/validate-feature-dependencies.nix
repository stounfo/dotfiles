{ lib }:

{ features }:

{ config, ... }:

let
  getFeatureDependencies =
    feature:
    if feature ? featureDependencies && builtins.isList feature.featureDependencies then
      feature.featureDependencies
    else
      [ ];

  getStringFeatureDependencies =
    feature: lib.filter builtins.isString (getFeatureDependencies feature);

  descriptorAssertions = lib.concatMap (
    name:
    let
      feature = features.${name};

      dependencies = getFeatureDependencies feature;

      stringDependencies = getStringFeatureDependencies feature;
    in
    [
      {
        assertion = !(feature ? featureDependencies) || builtins.isList feature.featureDependencies;

        message = "Feature ${name} field `featureDependencies` must be a list.";
      }

      {
        assertion =
          !(feature ? featureDependencies)
          || !builtins.isList feature.featureDependencies
          || lib.all builtins.isString feature.featureDependencies;

        message = "Feature ${name} field `featureDependencies` must contain only feature names.";
      }
    ]
    ++ map (dependency: {
      assertion = builtins.hasAttr dependency features;

      message = "Feature ${name} depends on unknown feature `${dependency}`.";
    }) stringDependencies
  ) (lib.attrNames features);

  dependencyAssertions = lib.concatMap (
    name:
    let
      feature = features.${name};

      dependencies = lib.filter (dependency: builtins.hasAttr dependency features) (
        getStringFeatureDependencies feature
      );
    in
    map (dependency: {
      assertion = !config.dots.features.${name}.enable || config.dots.features.${dependency}.enable;

      message = "Feature ${name} requires feature ${dependency}.";
    }) dependencies
  ) (lib.attrNames features);
in
{
  config.assertions = descriptorAssertions ++ dependencyAssertions;
}
