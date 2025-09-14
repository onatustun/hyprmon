{
  perSystem = {
    pkgs,
    config,
    inputs',
    ...
  }: {
    devShells.default = pkgs.mkShell {
      name = "hyprmon-shell";
      shellHook = config.pre-commit.installationScript;
      inputsFrom = [config.treefmt.build.devShell];

      packages = with pkgs;
        [
          git
          go
          gopls
          gotools
        ]
        ++ (with inputs'; [
          alejandra.packages.default
          deadnix.packages.default
        ]);
    };
  };
}
