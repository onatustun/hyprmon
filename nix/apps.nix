{
  perSystem = {self', ...}: {
    apps.default = {
      type = "app";
      program = "${self'.packages.default}/bin/hyprmon";
    };
  };
}
