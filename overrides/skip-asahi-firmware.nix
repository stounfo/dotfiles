{ lib, ... }:

{
  hardware.asahi.extractPeripheralFirmware = false;
  hardware.asahi.peripheralFirmwareDirectory = lib.mkForce null;
}
