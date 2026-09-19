{ lib, isNixOS, ... }:

lib.optionalAttrs isNixOS {
  programs.ssh = {
    startAgent = true;
    enableAskPassword = true;
  };
}
