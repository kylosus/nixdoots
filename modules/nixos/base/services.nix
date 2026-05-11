{
  params,
  pkgs,
  config,
  lib,
  vars,
  ...
}: let
  cfg = config.host.global;
  isI3 = cfg.windowManager == "i3";
  isHypr = cfg.windowManager == "hyprland";
in {
  # TODO: for now
  hardware.bluetooth = lib.mkIf cfg.desktop {
    enable = true;
  };

  programs = {
    # X11 only
    slock.enable = cfg.desktop && isI3;

    hyprland = lib.mkIf (cfg.desktop && isHypr) {
      enable = true;
      withUWSM = true;
      xwayland.enable = true;
    };
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
        KbdInteractiveAuthentication = false;
        AuthenticationMethods = "publickey";
      };
    };

    # TODO: remove after update
    blueman = {
      enable = cfg.desktop;
      withApplet = false;
    };

    udisks2.enable = cfg.desktop;

    displayManager = lib.mkIf cfg.desktop {
      enable = true;
      ly.enable = true;
      defaultSession =
        if isHypr
        then "hyprland-uwsm"
        else "none+i3";
    };

    # X11 only
    xserver = lib.mkIf (cfg.desktop && isI3) {
      enable = true;
      videoDrivers = ["nvidia"];
      deviceSection = ''Option "TearFree" "true"'';

      desktopManager.xterm.enable = false;

      windowManager.i3.enable = true;
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
      };
    };
  };

  # Polkit + portals + Wayland stuff for the desktop session.
  security.polkit.enable = lib.mkIf cfg.desktop true;

  xdg.portal = lib.mkIf cfg.desktop {
    enable = true;
    extraPortals =
      [pkgs.xdg-desktop-portal-gtk]
      ++ lib.optional isHypr pkgs.xdg-desktop-portal-hyprland;
    config = lib.mkIf isHypr {
      common.default = ["gtk"];
      hyprland = {
        default = ["hyprland" "gtk"];
        "org.freedesktop.impl.portal.Screencast" = ["hyprland"];
        "org.freedesktop.impl.portal.ScreenShot" = ["hyprland"];
      };
    };
  };

  environment.systemPackages = lib.optional cfg.desktop pkgs.pavucontrol;
}
