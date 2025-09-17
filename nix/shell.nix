{lib, ...}: let
  inherit (lib) concatLists;
in {
  perSystem = {
    pkgs,
    config,
    inputs',
    self',
    ...
  }: {
    devShells.default = pkgs.mkShell {
      name = "hyprmon-shell";
      shellHook = config.pre-commit.installationScript;
      inputsFrom = [config.treefmt.build.devShell];

      packages = concatLists [
        (with pkgs; [
          go_1_24
          go-tools
          gotools
        ])

        (with inputs'; [
          alejandra.packages.default
          deadnix.packages.default
          gomod2nix.packages.default
        ])

        [self'.packages.hyprmon]
      ];
    };
  };
}
