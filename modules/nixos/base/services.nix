{
  params,
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.host.global;
in {
  config = {
    # For locate and updatedb
    services.locate = lib.mkIf cfg.desktop {
      enable = true;
      localuser = null;
    };

    services.openssh = {
      enable = true;
      settings = {
        # For deploy-rs
        PermitRootLogin = "yes";
        PasswordAuthentication = false;
      };
    };

    services.displayManager = lib.mkIf cfg.desktop {
      enable = true;
      defaultSession = "none+i3";
    };

    services.xserver = lib.mkIf cfg.desktop {
      enable = true;

      videoDrivers = ["nvidia"];
      deviceSection = ''Option "TearFree" "true"'';

      libinput = {
        enable = true;

        mouse = {
          middleEmulation = true;
        };

        touchpad = {
          accelProfile = "adaptive";
          naturalScrolling = true;
        };
      };

      desktopManager = {
        xterm.enable = false;
      };

      displayManager = {
        startx.enable = true;
      };

      # TODO: Is this this duplicated with home-manager?
      windowManager.i3 = {
        enable = true;
      };
    };

    # TODO: not sure if I need to set all of them
    services.pipewire = lib.mkIf cfg.desktop {
      enable = true;
      wireplumber.enable = true;
      alsa.enable = true;
      pulse.enable = true;
      jack.enable = true;
    };

    environment.systemPackages = lib.optional cfg.desktop pkgs.pavucontrol;
  };
}
