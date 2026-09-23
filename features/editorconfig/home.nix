{ config, hostDescriptor, ... }:

{
  home.file.".editorconfig".source =
    config.lib.file.mkOutOfStoreSymlink "${hostDescriptor.repoRoot}/features/editorconfig/files/.editorconfig";
}
