{
  self,
  lib,
  inputs,
  ...
}: let
  version_rev =
    if (self ? rev)
    then (builtins.substring 0 8 self.rev)
    else "dirty";

  version = "${lib.fileContents ../VERSION}-${version_rev}-flake";
  vendorHash = lib.fileContents ../go.mod.sri;
in {
  perSystem = {
    pkgs,
    lib,
    self',
    ...
  }: {
    packages = rec {
      hyprmon = pkgs.buildGoModule {
        pname = "hyprmon";
        inherit version;
        src = inputs.gitignore.lib.gitignoreSource ./..;
        inherit vendorHash;
        env.CGO_ENABLED = 0;

        meta = with lib; {
          homepage = "https://github.com/erans/hyprmon";
          description = "TUI monitor configuration tool for Hyprland with visual layout, drag-and-drop, and profile management";
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
