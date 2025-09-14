{
  perSystem = {self', ...}: {
    apps = rec {
      hyprmon = {
        type = "app";
        program = "${self'.packages.default}/bin/hyprmon";
      };

      default = hyprmon;
    };
  };
}
