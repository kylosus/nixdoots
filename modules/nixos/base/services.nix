{
  params,
  pkgs,
  ...
}: {
  # services.xserver.enable = true;
  # services.xserver.desktopManager.gnome.enable = true;
  # services.xserver.displayManager.gdm.enable = true;
  #services.xserver.displayManager.autoLogin = {
  #  enable = true;
  #  user = params.username;
  #};

  services.displayManager.defaultSession = "none+i3";

  services.supergfxd.enable = true;

  services.asusd = {
    enable = true;
    enableUserService = true;
  };

  services.xserver = {
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
      # defaultSession = "none+i3";
    };

    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        dmenu
      ];
    };
  };

  # Needed for autologin for now
  #  systemd.services."getty@tty1".enable = false;
  #  systemd.services."autovt@tty1".enable = false;

  services.pipewire = {
    enable = true;
    wireplumber.enable = true;
    alsa.enable = true;
    pulse.enable = true;
    jack.enable = true;
  };

  environment.systemPackages = with pkgs; [
    pavucontrol
  ];

  # The below is for GPG pinentry with gnome 3
  services.dbus.packages = [pkgs.gcr];

  # For locate and updatedb
  services.locate = {
    enable = true;
    localuser = null;
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };
}
