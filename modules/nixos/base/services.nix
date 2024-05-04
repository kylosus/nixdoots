{
  params,
  pkgs,
  config,
  lib,
  vars,
  ...
}: let
  cfg = config.host.global;
in {
  # TODO: for now
  hardware.bluetooth = lib.mkIf cfg.desktop {
    enable = true;
  };

  services = {
    # SSH tarpit
    endlessh-go = {
      enable = true;
      port = 22;
    };

    openssh = {
      enable = true;
      ports = [vars.ssh.port];
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
    };

    blueman.enable = cfg.desktop;

    # For locate and updatedb
    locate = lib.mkIf cfg.desktop {
      enable = false;
      localuser = null;
    };

    displayManager = lib.mkIf cfg.desktop {
      enable = true;
      defaultSession = "none+i3";
    };

    xserver = lib.mkIf cfg.desktop {
      enable = true;
      videoDrivers = ["nvidia"];
      deviceSection = ''Option "TearFree" "true"'';

      desktopManager = lib.mkIf cfg.desktop {
        xterm.enable = false;
      };

      displayManager = lib.mkIf cfg.desktop {
        startx.enable = true;
      };

      # TODO: Is this this duplicated with home-manager?
      windowManager.i3 = lib.mkIf cfg.desktop {
        enable = true;
      };
    };

    libinput = lib.mkIf cfg.desktop {
      enable = true;

      mouse = {
        middleEmulation = true;
      };

      touchpad = {
        accelProfile = "adaptive";
        naturalScrolling = true;
      };
    };

    pipewire = lib.mkIf cfg.desktop {
      enable = true;
      wireplumber.enable = true;
      alsa.enable = true;
      pulse.enable = true;
      jack.enable = true;
    };
  };

  environment.systemPackages = lib.optional cfg.desktop pkgs.pavucontrol;
}
