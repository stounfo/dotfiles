{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../apple-silicon-support
  ];

  hardware.asahi = {
    enable = true;
    peripheralFirmwareDirectory = /boot/vendorfw;
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;

  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
  };

  time.timeZone = "Asia/Yerevan";

  services.displayManager.regreet.enable = true;
  services.upower.enable = true;
  services.greetd.enable = true;

  users.users.stounfo = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "26.11";
}
