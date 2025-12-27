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

    # python3 = prev.python3.override {
    #   packageOverrides = self: super: {
    #     dbus-python = super.dbus-python.overrideAttrs (oldAttrs: {
    #       nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [prev.dbus];
    #     });
    #   };
    # };

    # TODO: annoying packages
    gtk4 = final.stable.gtk4;
    ffmpeg = final.stable.ffmpeg;

    # TODO: Some OpenSSH apps break when config file is a symlink
    # See https://github.com/nix-community/home-manager/issues/322#issuecomment-1178614454
    openssh-patched = prev.openssh.overrideAttrs (old: {
      patches =
        (old.patches or [])
        ++ [
          (builtins.toFile "openssh-ssh-config.patch"
            ''              diff --git a/readconf.h b/readconf.h
                            index ded13c9..94f489e 100644
                            --- a/readconf.h
                            +++ b/readconf.h
                            @@ -203,7 +203,7 @@ typedef struct {
                            #define SESSION_TYPE_SUBSYSTEM	1
                            #define SESSION_TYPE_DEFAULT	2

                            -#define SSHCONF_CHECKPERM	1  /* check permissions on config file */
                            +#define SSHCONF_CHECKPERM	0  /* check permissions on config file */
                            #define SSHCONF_USERCONF	2  /* user provided config file not system */
                            #define SSHCONF_FINAL		4  /* Final pass over config, after canon. */
                            #define SSHCONF_NEVERMATCH	8  /* Match/Host never matches; internal only */
            '')
        ];
      doCheck = false;
    });
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      stdenv.hostPlatform.system = final.system;
      config.allowUnfree = true;
    };
    nix-alien = inputs.nix-alien.packages.${final.system}.nix-alien;
  };

  stable-packages = final: _prev: {
    stable = import inputs.nixpkgs-stable {
      stdenv.hostPlatform.system = final.system;
      config.allowUnfree = true;
    };
  };
}
