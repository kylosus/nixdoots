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
    endlessh-go = lib.mkIf cfg.endlessh {
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
      alsa.enable = true;
      pulse.enable = true;
      jack.enable = true;

      wireplumber = {
        enable = true;
        # extraConfig."99-mute-default-sink" = {
        #   "device.routes.default-sink-volume" = "0";
        # };
      };
    };
  };

  environment.systemPackages = lib.optional cfg.desktop pkgs.pavucontrol;
}
