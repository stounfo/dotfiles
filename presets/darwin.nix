{ lib, ... }:

{
  dots.features.raycast.enable = lib.mkDefault true;
  dots.features.chatgpt.enable = lib.mkDefault true;
}
