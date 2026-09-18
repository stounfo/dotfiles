{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./apple-silicon-support
    ];
  hardware.asahi.enable = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;

  # networking.hostName = "nixos"; # Define your hostname.

  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;
  networking.hostName = "nixos";

  # Set your time zone.
  time.timeZone = "Asia/Yerevan";

  programs.hyprland.enable = true;
  programs.regreet.enable = true;

  # Noctalia uses UPower to discover and monitor the laptop battery.
  services.upower.enable = true;

  services.greetd = {
    enable = true;
  };
  
  users.users.stounfo = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
  };


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

