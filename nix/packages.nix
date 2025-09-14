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
    pkgs,
    self',
    ...
  }: {
    packages = let
      inherit (pkgs.extend inputs.gomod2nix.overlays.default) buildGoApplication;
      inherit (inputs.gitignore.lib) gitignoreSource;
    in rec {
      hyprmon = buildGoApplication {
        go = pkgs.go_1_24;
        pname = "hyprmon";
        inherit version;

        subPackages = ["."];
        CGO_ENABLED = "0";

        src = gitignoreSource ./..;
        pwd = self;
        modules = self + "/gomod2nix.toml";

        meta = with lib; {
          description = "TUI monitor configuration tool for Hyprland with visual layout, drag-and-drop, and profile management";
          homepage = "https://github.com/erans/hyprmon";
          license = licenses.asl20;
          mainProgram = "hyprmon";
          platforms = platforms.linux;
        };
      };

      default = hyprmon;
    };

    checks.default = self'.packages.default;
  };
}
