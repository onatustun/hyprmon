{
  lib,
  self,
  inputs,
  ...
}: let
  inherit (lib) substring fileContents;

  versionRev =
    if self ? rev
    then substring 0 8 self.rev
    else "dirty";

  version = "${fileContents (self + "/VERSION")}-${versionRev}-flake";
in {
  perSystem = {
    system,
    pkgs,
    self',
    ...
  }: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;

      overlays = with inputs; [
        gitignore.overlay
        gomod2nix.overlays.default
      ];
    };

    packages = rec {
      hyprmon = pkgs.buildGoApplication {
        go = pkgs.go_1_24;
        pname = "hyprmon";
        inherit version;

        subPackages = ["."];
        CGO_ENABLED = "0";

        src = pkgs.gitignoreSource ./..;
        pwd = self;
        modules = self + "/gomod2nix.toml";

        meta = with lib; {
          description = "TUI monitor configuration tool for Hyprland with visual layout, drag-and-drop, and profile management";
          homepage = "https://github.com/erans/hyprmon";
          license = licenses.asl20;
          mainProgram = "hyprmon";
          maintainers = with maintainers; [onatustun];
          platforms = platforms.linux;
        };
      };

      default = hyprmon;
    };

    checks.default = self'.packages.default;
  };
}
