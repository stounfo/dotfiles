{
  lib,
  nixpkgs,
  systems,
}:

lib.genAttrs (builtins.attrValues systems) (
  system:
  let
    pkgs = nixpkgs.legacyPackages.${system};
  in
  {
    default = pkgs.mkShellNoCC {
      packages = with pkgs; [
        gnumake
        treefmt
        nixfmt
        prettier
        typos
        lefthook
        deadnix
        statix
      ];
    };
  }
)
