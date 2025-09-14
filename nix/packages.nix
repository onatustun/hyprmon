{
  pkgs,
  inputs,
  lib,
  ...
}: {
  perSystem = {self', ...}: {
    packages.default = pkgs.buildGoModule {
      pname = "hyprmon";
      version = "0.0.8";
      src = inputs.gitignore.lib.gitignoreSource ./.;
      vendorHash = "sha256-D3hd5GN7I7sV/dSWj45cMn0oyKDHZ1rE26OWWU34lFU=";

      meta = with lib; {
        description = "TUI monitor configuration tool for Hyprland with visual layout, drag-and-drop, and profile management";
        license = licenses.asl20;
        mainProgram = "hyprmon";
        platforms = platforms.linux;
      };
    };

    checks.default = self'.packages.default;
  };
}
