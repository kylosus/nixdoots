# This file defines overlays
{inputs, ...}: {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs {pkgs = final;};

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });

    #asusctl = prev.asusctl.override (old: {
    #  rustPlatform =
    #    old.rustPlatform
    #    // {
    #      buildRustPackage = args:
    #       old.rustPlatform.buildRustPackage (args
    #          // {
    #            src = final.fetchFromGitLab {
    #              owner = "asus-linux";
    #              repo = "asusctl";
    #              rev = "5.0.10";
    #              hash = "sha256-H8x3nfOFRv9DkbDkFw+LO1tdHiVyU3SzetqED4twPSk=";
    #            };
    #            # cargoHash = "sha256-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX=";
    #            # cargoHash = "sha256-753560b6ae8edf72a4a9c6f0e5b187590184b1106375634ac2a95ad245c47275";
    #            cargoHash = "sha256-H8x3nfOFRv9DkbDkFw+LO1tdHiVyU3SzetqED4twPSk=";
    #            cargoLock = {
    #             lockFile = ./Cargo.lock;
    #              outputHashes = {
    #                "ecolor-0.21.0" = "sha256-m7eHX6flwO21umtx3dnIuVUnNsEs3ZCyOk5Vvp/lVfI=";
    #                "notify-rust-4.6.0" = "sha256-jhCgisA9f6AI9e9JQUYRtEt47gQnDv5WsdRKFoKvHJs=";
    #                "supergfxctl-5.1.2" = "sha256-WDbUgvWExk5cs2cpjo88CiROdEbc01o2DELhRi9gju4=";
    #              };
    #            };
    #          });
    #    };
    #});

    # rxvt-unicode = prev.rxvt-unicode.overrideAttrs (old: {
    #   emojiSupport = true;
    # });

    #pywal = prev.pywal.overrideAttrs (old: {
    #  src = prev.fetchFromGitHub {
    #   owner = "dylanaraps";
    #   repo = "pywal";
    #   rev = "master";
    #   hash = "sha256-La6ErjbGcUbk0D2G1eriu02xei3Ki9bjNme44g4jAF0=";
    # };
    # patches = [];
    # doCheck = false;
    # doInstallCheck = false;
    #
    #     propagatedBuildInputs = old.propagatedBuildInputs ++ [final.imagemagick];
    #    });

    #    pywal = inputs.nixpkgs.legacyPackages.x86_64-linux.pkgs.python3.override {
    #      packageOverrides = self: super: {
    #
    #      };
    #    };

    ranger = prev.ranger.overrideAttrs (old: {
      propagatedBuildInputs = old.propagatedBuildInputs ++ [final.screen];
    });

    # https://nixos.wiki/wiki/MPV
    mpv-unwrapped = prev.mpv-unwrapped.override {
      lua = final.luajit;
    };
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.system;
      config.allowUnfree = true;
    };
    nix-alien = inputs.nix-alien.packages.${final.system}.nix-alien;
  };
}
