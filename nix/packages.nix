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
  vendorHash = fileContents (self + "/go.mod.sri");
in {
  perSystem = {
    pkgs,
    self',
    ...
  }: {
    packages = let
      inherit (pkgs) buildGoModule;
      inherit (inputs.gitignore.lib) gitignoreSource;
    in rec {
      hyprmon = buildGoModule {
        pname = "hyprmon";
        inherit version vendorHash;
        src = gitignoreSource ./..;
        env.CGO_ENABLED = "0";

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
