{
  config,
  pkgs,
  lib,
  hostDescriptor,
  ...
}:

{
  home = {
    packages = [ pkgs.bash ];
    sessionPath = [ "${config.home.homeDirectory}/.local/bin" ];

    file =
      lib.genAttrs [ ".local/bin/dnote" ".local/bin/snote" ".local/bin/knote" ]
        (path: {
          source = config.lib.file.mkOutOfStoreSymlink "${hostDescriptor.repoRoot}/features/my-sh-commands/files/${builtins.baseNameOf path}";
        });
  };
}
