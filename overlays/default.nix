# This file defines overlays
{inputs, ...}: {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs {pkgs = final;};

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    pywal = prev.pywal.overrideAttrs (old: {
      src = prev.fetchFromGitHub {
        owner = "dylanaraps";
        repo = "pywal";
        rev = "master";
        hash = "sha256-La6ErjbGcUbk0D2G1eriu02xei3Ki9bjNme44g4jAF0=";
      };
      patches = [];
      doCheck = false;
      doInstallCheck = false;

      propagatedBuildInputs = old.propagatedBuildInputs ++ [final.imagemagick];
    });

    ranger =
      (prev.ranger.overrideAttrs (old: {
        propagatedBuildInputs = old.propagatedBuildInputs ++ [final.screen];
        sixelPreviewSupport = false;
      }))
      .override {
        # For aarch64-linux
        sixelPreviewSupport = false;
      };

    w3m = prev.w3m.override {
      graphicsSupport = false;
    };

    # https://nixos.wiki/wiki/MPV
    mpv-unwrapped = prev.mpv-unwrapped.override {
      lua = final.luajit;
    };

    networkmanager = prev.networkmanager.override {
      openconnect = null;
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
}
