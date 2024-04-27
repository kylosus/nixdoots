{
  params,
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.host.global;
  has_desktop = cfg.desktop;
in {
  config = {
    # For locate and updatedb
    services.locate = {
      enable = has_desktop;
      localuser = null;
    };

    services.openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
    };

    services.displayManager = {
      enable = has_desktop;
      defaultSession = "none+i3";
    };

    services.xserver = {
      enable = has_desktop;

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

    services.pipewire = {
      enable = has_desktop;
      wireplumber.enable = true;
      alsa.enable = true;
      pulse.enable = true;
      jack.enable = true;
    };

    environment.systemPackages = lib.optional has_desktop pkgs.pavucontrol;
  };
}
