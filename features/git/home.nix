{
  pkgs,
  config,
  hostDescriptor,
  ...
}:

{
  home.packages = [ pkgs.git ];

  home.file.".gitconfig".source =
    config.lib.file.mkOutOfStoreSymlink "${hostDescriptor.repoRoot}/features/git/files/.gitconfig";

  home.file.".gitignore".source =
    config.lib.file.mkOutOfStoreSymlink "${hostDescriptor.repoRoot}/features/git/files/.gitignore";
}
