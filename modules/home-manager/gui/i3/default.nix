{
  config,
  lib,
  pkgs,
  files,
  params,
  ...
}: {
  imports = [
    ./common.nix
    ./dunst.nix
    ./i3.nix
    ./polybar.nix
    ./rofi.nix
    ./screen-locker.nix
    ./wal.nix
  ];

  # .xinitrc fix
  home.file.".xinitrc".source = ./xinitrc;

  home.packages = with pkgs; [
    xclip
    xsel
    nautilus
    font-awesome_6
  ];

  programs.feh.enable = true;

  xdg.mimeApps.defaultApplications = {
    "image/bmp" = lib.mkForce "feh.desktop";
    "image/gif" = lib.mkForce "feh.desktop";
    "image/jpeg" = lib.mkForce "feh.desktop";
    "image/jpg" = lib.mkForce "feh.desktop";
    "image/pjpeg" = lib.mkForce "feh.desktop";
    "image/png" = lib.mkForce "feh.desktop";
    "image/tiff" = lib.mkForce "feh.desktop";
    "image/webp" = lib.mkForce "feh.desktop";
    "image/x-bmp" = lib.mkForce "feh.desktop";
    "image/x-pcx" = lib.mkForce "feh.desktop";
    "image/x-png" = lib.mkForce "feh.desktop";
    "image/x-portable-anymap" = lib.mkForce "feh.desktop";
    "image/x-portable-bitmap" = lib.mkForce "feh.desktop";
    "image/x-portable-graymap" = lib.mkForce "feh.desktop";
    "image/x-portable-pixmap" = lib.mkForce "feh.desktop";
    "image/x-tga" = lib.mkForce "feh.desktop";
    "image/x-xbitmap" = lib.mkForce "feh.desktop";
  };

  xsession.enable = true;

  # TODO: This can be better
  xdg.userDirs.extraConfig = {
    XDG_SCREENSHOTS_DIR = "${config.xdg.userDirs.pictures}/Screenshots";
  };

  services = {
    # TODO: qtwebengine compile
    #  flameshot = {
    #    enable = true;
    #    settings = {
    #      General = {
    #        showStartupLaunchMessage = false;
    #        savePath = "${config.xdg.userDirs.pictures}/Screenshots";
    #      };
    #      Shortcuts = {
    #        TYPE_COPY = "Return";
    #      };
    #    };
    #  };
    picom = {
      enable = true;
      vSync = false;
    };
  };

  systemd.user = {
    targets.i3-session = {
      Unit = {
        Description = "i3 session";
        Documentation = ["man:systemd.special(7)"];
        BindsTo = ["graphical-session.target"];
        Wants = ["graphical-session-pre.target"];
        After = ["graphical-session-pre.target"];
      };
    };
    services = {
      feh = {
        Unit = {
          Description = "feh background";
          PartOf = ["i3-session.target"];
          After = ["xrandr.service" "picom.service"];
        };
        Service = {
          ExecStart = "${pkgs.feh}/bin/feh --bg-fill ${params.wallpaper}";
          RemainAfterExit = true;
          Type = "oneshot";
        };
        Install.WantedBy = ["i3-session.target"];
      };

      urxvtd = {
        Unit = {
          Description = "rxvt daemon";
          PartOf = ["i3-session.target"];
          After = ["xrandr.service" "picom.target"];
        };
        Service = {
          ExecStart = "${config.programs.urxvt.package}/bin/urxvtd -o -q";
          # RemainAfterExit = true;
          Type = "simple";
        };
        Install.WantedBy = ["i3-session.target"];
      };

      pywal = {
        Unit = {
          Description = "wal background";
          PartOf = ["i3-session.target"];
          After = ["xrandr.service" "picom.service"];
        };
        Service = {
          ExecStart = "${pkgs.pywal}/bin/wal -a 90 -i ${params.wallpaper}";
          Type = "oneshot";
        };
        Install.WantedBy = ["i3-session.target"];
      };

      # flameshot.Install.WantedBy = lib.mkForce ["i3-session.target"]; # TODO: qtwebengine compile
      picom = {
        Unit.After = ["xrandr.service"];
        Install.WantedBy = lib.mkForce ["i3-session.target"];
      };
    };
  };
}
