{
  params,
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.host.global;
in {
  # TODO: for now
  hardware.bluetooth = lib.mkIf cfg.desktop {
    enable = true;
  };

  services =
    {
      openssh = {
        enable = true;
        settings = {
          PermitRootLogin = "no";
          PasswordAuthentication = false;
        };
      };
    }
    // lib.mkIf cfg.desktop {
      blueman.enable = true;

      # For locate and updatedb
      locate = {
        enable = true;
        localuser = null;
      };

      displayManager = {
        enable = true;
        defaultSession = "none+i3";
      };

      xserver = {
        enable = true;
        videoDrivers = ["nvidia"];
        deviceSection = ''Option "TearFree" "true"'';

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

      pipewire = {
        enable = true;
        wireplumber.enable = true;
        alsa.enable = true;
        pulse.enable = true;
        jack.enable = true;
      };
    };

  environment.systemPackages = lib.optional cfg.desktop pkgs.pavucontrol;
}
