{ config, hostDescriptor, ... }:

{
  home.file.".ssh/config".source =
    config.lib.file.mkOutOfStoreSymlink "${hostDescriptor.repoRoot}/features/ssh/files/config";
}
