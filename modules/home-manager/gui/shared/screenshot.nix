{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.host.global;
  isHypr = cfg.windowManager == "hyprland";
in {
  options.host.screenshot = {
    command = lib.mkOption {
      type = lib.types.str;
      description = "Shell command bound to PrtSc that takes an interactive screenshot.";
    };
  };

  config = lib.mkMerge [
    # The screenshots directory is WM-agnostic.
    {
      xdg.userDirs.extraConfig = {
        SCREENSHOTS = "${config.xdg.userDirs.pictures}/Screenshots";
      };
    }

    (lib.mkIf (!isHypr) {
      services.flameshot = {
        enable = true;
        package = pkgs.stable.flameshot; # qtwebengine compile workaround
        settings = {
          General = {
            showStartupLaunchMessage = false;
            savePath = "${config.xdg.userDirs.pictures}/Screenshots";
          };
          Shortcuts = {
            TYPE_COPY = "Return";
          };
        };
      };

      systemd.user.services.flameshot.Install.WantedBy = lib.mkForce ["${config.host.session.target}"];

      host.screenshot.command = "${lib.getBin pkgs.stable.flameshot}/bin/flameshot gui";
    })

    # TODO: replace
    (lib.mkIf isHypr {
      home.packages = with pkgs; [
        grimblast
        grim
        slurp
        swappy
        wl-clipboard
        cliphist
        hyprpicker
      ];

      host.screenshot.command = "${pkgs.grimblast}/bin/grimblast --notify copysave area";
    })
  ];
}
