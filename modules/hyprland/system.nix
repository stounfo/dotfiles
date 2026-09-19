{ lib, isNixOS, ... }:

# NixOS integration: display-manager session, portals and system permissions.
lib.optionalAttrs isNixOS {
  programs.hyprland.enable = true;
}
