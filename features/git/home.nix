{
  pkgs,
  config,
  hostDescriptor,
  ...
}:

{
  home = {
    packages = [ pkgs.git ];

    file.".gitconfig".source =
      config.lib.file.mkOutOfStoreSymlink "${hostDescriptor.repoRoot}/features/git/files/.gitconfig";

    file.".gitignore".source =
      config.lib.file.mkOutOfStoreSymlink "${hostDescriptor.repoRoot}/features/git/files/.gitignore";
  };
}
