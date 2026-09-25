{
  inputs,
  pkgs,
  ...
}:

let
  firmware = pkgs.requireFile {
    name = "firmware.cpio";
    hash = "sha256-s/DgcZEHWZ68HWvHUpa+ictdK1GV8M4i5SYbPH+DTXY=";
    message = ''
      Import firmware first:
      nix-store --add-fixed sha256 /boot/vendorfw/firmware.cpio
    '';
  };
in
{
  imports = [
    ../../presets/common.nix
    ../../presets/linux.nix

    ./hardware-configuration.nix
    inputs.nixos-apple-silicon.nixosModules.apple-silicon-support
  ];

  hardware.asahi = {
    enable = true;
    peripheralFirmwareDirectory = pkgs.runCommand "asahi-vendor-firmware" { } ''
      mkdir -p "$out"
      ln -s ${firmware} "$out/firmware.cpio"
    '';
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;
}
