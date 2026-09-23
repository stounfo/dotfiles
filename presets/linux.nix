{ lib, ... }:

{
  dots.features.bluetooth.enable = lib.mkDefault true;
  dots.features.desktop.enable = lib.mkDefault true;
  dots.features.power-management.enable = lib.mkDefault true;
  dots.features.networking.enable = lib.mkDefault true;
  dots.features.timezone.enable = lib.mkDefault true;
}
