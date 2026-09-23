{ lib }:

{ condition, fragment }:

let
  fragmentValue = import fragment;

  fragmentArgs = if builtins.isFunction fragmentValue then lib.functionArgs fragmentValue else { };

  conditionArgs = lib.functionArgs condition;

  argumentNames = lib.unique (lib.attrNames fragmentArgs ++ lib.attrNames conditionArgs);

  moduleArgs = lib.genAttrs argumentNames (
    name: (fragmentArgs.${name} or true) && (conditionArgs.${name} or true)
  );

  module = args: {
    config = lib.mkIf (condition args) (
      if builtins.isFunction fragmentValue then fragmentValue args else fragmentValue
    );
  };
in

lib.setFunctionArgs module moduleArgs
