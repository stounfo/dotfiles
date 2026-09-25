{ lib, ... }:

{
  dots.features = {
    bluetooth.enable = lib.mkDefault true;
    desktop.enable = lib.mkDefault true;
    power-management.enable = lib.mkDefault true;
    networking.enable = lib.mkDefault true;
    timezone.enable = lib.mkDefault true;
  };
}
