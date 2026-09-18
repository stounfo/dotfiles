{ pkgs, ... }:

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

  programs.hyprland.enable = true;

  services.displayManager.regreet.enable = true;
  services.upower.enable = true;
  services.greetd.enable = true;

  users.users.stounfo = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    vim
    ghostty
    chromium
    walker
    elephant
    bibata-cursors
    codex
    noctalia-shell
    bluez
    git
  ];

  environment.sessionVariables = {
    XCURSOR_THEME = "Bibata-Modern-Ice";
    XCURSOR_SIZE = "24";
    HYPRCURSOR_THEME = "Bibata-Modern-Ice";
    HYPRCURSOR_SIZE = "24";
  };

  system.stateVersion = "26.11";
}
