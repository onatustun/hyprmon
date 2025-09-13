{
  description = "TUI monitor configuration tool for Hyprland with visual layout, drag-and-drop, and profile management";

  nixConfig = {
    extra-substituters = [
      "https://alejandra.cachix.org"
      "https://cache.garnix.io"
      "https://cachix.cachix.org"
      "https://deadnix.cachix.org"
      "https://flake-parts.cachix.org"
      "https://hercules-ci.cachix.org"
      "https://nix-community.cachix.org"
      "https://pre-commit-hooks.cachix.org"
    ];

    extra-trusted-public-keys = [
      "alejandra.cachix.org-1:NjZ8kI0mf4HCq8yPnBfiTurb96zp1TBWl8EC54Pzjm0="
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM="
      "deadnix.cachix.org-1:R7kK+K1CLDbLrGph/vSDVxUslAmq8vhpbcz6SH9haJE="
      "flake-parts.cachix.org-1:IlewuHm3lWYND+tOeQC9nySl7JpzTZ4sqkb1eJMafow="
      "hercules-ci.cachix.org-1:ZZeDl9Va+xe9j+KqdzoBZMFJHVQ42Uu/c/1/KMC5Lw0="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "pre-commit-hooks.cachix.org-1:Pkk3Panw5AW24TOv6kz3PvLhlH8puAsJTBbOPmBo7Rc="
    ];

    builders-use-substitutes = true;

    experimental-features = [
      "flakes"
      "nix-command"
      "pipe-operators"
    ];

    flake-registry = "";
    show-trace = true;
  };
  
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    systems.url = "github:nix-systems/default-linux";

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };

    flake-root.url = "github:srid/flake-root";

    gitignore = {
      url = "github:hercules-ci/gitignore.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";

      inputs = {
        flake-compat.follows = "flake-compat";
        gitignore.follows = "gitignore";
        nixpkgs.follows = "nixpkgs";
      };
    };

    alejandra = {
      url = "github:kamadorueda/alejandra";

      inputs = {
        flakeCompat.follows = "flake-compat";
        nixpkgs.follows = "nixpkgs";
      };
    };

    deadnix = {
      url = "github:astro/deadnix";

      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
  };

  outputs = inputs @ {
    nixpkgs,
    flake-parts,
    systems,
    flake-root,
    pre-commit-hooks,
    treefmt-nix,
    gitignore,
    ...
  }: let
    inherit (nixpkgs) lib;
  in
    flake-parts.lib.mkFlake {inherit inputs;} {
      debug = true;
      systems = import systems;

      imports = [
        flake-root.flakeModule
        pre-commit-hooks.flakeModule
        treefmt-nix.flakeModule
      ];

      perSystem = {
        pkgs,
        self',
        config,
        inputs',
        ...
      }: {
        packages.default = pkgs.buildGoModule {
          pname = "hyprmon";
          version = "0.0.8";
          src = gitignore.lib.gitignoreSource ./.;
          vendorHash = "sha256-D3hd5GN7I7sV/dSWj45cMn0oyKDHZ1rE26OWWU34lFU=";
          env.CGO_ENABLED = 0;
          subPackages = ["."];

          meta = with lib; {
            description = "TUI monitor configuration tool for Hyprland with visual layout, drag-and-drop, and profile management";
            license = licenses.asl20;
            mainProgram = "hyprmon";
            platforms = platforms.linux;
          };
        };

        apps.default = {
          type = "app";
          program = "${self'.packages.default}/bin/hyprmon";
        };

        pre-commit = {
          check.enable = true;

          settings = {
            package = inputs'.pre-commit-hooks.packages.default;

            excludes = [
              "\\.envrc$"
              "flake\\.lock$"
            ];

            hooks = {
              alejandra = {
                enable = true;
                package = inputs'.alejandra.packages.default;
              };

              deadnix = {
                enable = true;
                package = inputs'.deadnix.packages.default;
              };

              treefmt.enable = true;
            };
          };
        };

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

        formatter = config.treefmt.build.wrapper;

        treefmt = {
          inherit (config.flake-root) projectRootFile;
          enableDefaultExcludes = true;

          settings.global.excludes = [
            "*.envrc"
            "flake.lock"
          ];

          programs = {
            alejandra = {
              enable = true;
              package = inputs'.alejandra.packages.default;
            };

            deadnix = {
              enable = true;
              package = inputs'.deadnix.packages.default;
            };
          };
        };

        checks.default = self'.packages.default;
      };
    };
}