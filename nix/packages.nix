{inputs, ...}: {
  perSystem = {
    pkgs,
    lib,
    self',
    ...
  }: {
    packages = rec {
      hyprmon = pkgs.buildGoModule {
        pname = "hyprmon";
        version = "0.0.8";
        src = inputs.gitignore.lib.gitignoreSource ./..;
        vendorHash = "sha256-D3hd5GN7I7sV/dSWj45cMn0oyKDHZ1rE26OWWU34lFU=";

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
