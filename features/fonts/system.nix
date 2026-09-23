{ pkgs, ... }:

{
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.martian-mono
    nerd-fonts.iosevka-term
    nerd-fonts.blex-mono
  ];
}
