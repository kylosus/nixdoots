# This file defines overlays
{
  inputs,
  lib,
  config,
  ...
}: let
  cfg = config.host.global;
in {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs {pkgs = final;};

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });
    ranger =
      (prev.ranger.overrideAttrs (old: {
        propagatedBuildInputs = old.propagatedBuildInputs ++ [final.screen];
        sixelPreviewSupport = cfg.desktop;
      }))
      .override {
        # For aarch64-linux
        sixelPreviewSupport = cfg.desktop;
      };

    w3m = prev.w3m.override {
      graphicsSupport = cfg.desktop;
    };

    # https://nixos.wiki/wiki/MPV
    mpv-unwrapped = prev.mpv-unwrapped.override {
      lua = final.luajit;
    };

    #python3Packages.dbus-python = prev.python3Packages.dbus-python.overrideAttrs(old: {
    #  # nativeBuildInputs = old.nativeBuildInputs ++ [ prev.dbus ];
    #});

    python3 = prev.python3.override {
      packageOverrides = self: super: {
        dbus-python = super.dbus-python.overrideAttrs (oldAttrs: {
          nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [prev.dbus];
        });
      };
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

  stable-packages = final: _prev: {
    stable = import inputs.nixpkgs-stable {
      system = final.system;
      config.allowUnfree = true;
    };
  };
}
