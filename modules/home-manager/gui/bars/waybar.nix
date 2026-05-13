{
  config,
  pkgs,
  lib,
  ...
}: let
  bar = config.host.bar;
  hasBattery = bar.battery != null;

  # When monitors are explicitly listed, attach the bar to all of them
  # (waybar duplicates the bar across listed outputs). Otherwise leave unset
  # so waybar follows compositor defaults.
  outputs = bar.monitors;
in {
  home.packages = with pkgs; [
    dejavu_fonts
    font-awesome_7
  ];

  programs.waybar = {
    enable = true;
    systemd.enable = true;

    settings.mainBar = {
      layer = "top";
      position = "bottom";
      height = 36;
      spacing = 4;

      modules-center = [
        "custom/split"
        "mpris"
        "custom/split"
      ];

      modules-left = lib.intersperse "custom/split" [
        "hyprland/workspaces"
        "hyprland/window"
      ];
      modules-right = lib.intersperse "custom/split" (
        [
          "pulseaudio"
          "network"
        ]
        ++ lib.optional hasBattery "battery"
        ++ [
          "disk"
          "memory"
          "cpu"
          "temperature"
          "tray"
          "clock"
          "custom/power"
        ]
      );

      "custom/split" = {
        format = "|";
        tooltip = false;
      };

      "hyprland/workspaces" = {
        format = "{name}";
        on-click = "activate";
        all-outputs = false;
        sort-by-number = true;
      };

      "hyprland/window" = {
        format = "{}";
        max-length = 64;
        separate-outputs = true;
      };

      pulseaudio = {
        format = "{icon} {volume}%";
        format-muted = " {volume}%";
        format-icons = {
          default = ["" "" ""];
        };
        scroll-step = 3;
        on-click = "${config.host.audio.cmd.mute}";
        on-click-middle = "${pkgs.pavucontrol}/bin/pavucontrol";
      };

      network = {
        interface = bar.ifname;
        interval = 3;
        format-wifi = " {bandwidthDownBytes}   {bandwidthUpBytes}";
        format-ethernet = " {bandwidthDownBytes}   {bandwidthUpBytes}";
        format-disconnected = " disconnected";
        tooltip-format = "{ifname} via {ipaddr}";
      };

      battery = lib.mkIf hasBattery {
        bat = bar.battery.battery;
        adapter = bar.battery.adapter;
        interval = 30;
        full-at = 99;
        format = "{icon} {capacity}%";
        format-charging = " {capacity}%";
        format-icons = ["" "" "" "" ""];
        states = {
          warning = 30;
          critical = 15;
        };
      };

      disk = {
        path = "/";
        interval = 60;
        format = " {percentage_used}%";
      };

      memory = {
        interval = 2;
        format = " {percentage}%";
      };

      cpu = {
        interval = 2;
        format = " {usage}%";
      };

      temperature = {
        critical-threshold = 80;
        interval = 2;
        format = "{icon} {temperatureC}°C";
        format-icons = ["" "" ""];
      };

      clock = {
        interval = 1;
        format = " {:%H:%M:%S}";
        format-alt = " {:%d.%m.%Y %H:%M:%S}";
        tooltip-format = "<tt><big>{calendar}</big></tt>";
      };

      mpris = {
        interval = 1;
        format = "{player_icon} {dynamic}";
        format-paused = "{status_icon} <i>{dynamic}</i>";
        player-icons = {
          default = "";
          chromium = "";
          spotify = "";
        };
        status-icons = {
          paused = "";
        };
      };

      tray = {
        # icon-size = 18;
        spacing = 4;
        # Per-app icon overrides.
        # See https://github.com/Alexays/Waybar/wiki/Module:-Tray
        icons = {
          blueman = "${./tray-icons/bluetooth.png}";
          discord = "${./tray-icons/discord.png}";
        };
      };

      "custom/power" = {
        format = "";
        tooltip = false;
        on-click = "${pkgs.wlogout}/bin/wlogout || true";
      };
    };

    style = ''
      @import url("file://${config.home.homeDirectory}/.cache/wal/colors-waybar.css");

      * {
        font-family: "DejaVu Sans", "Font Awesome 7 Free Solid";
        font-size: 13px;
        min-height: 0;
        border: none;
        border-radius: 0;
      }

      window#waybar {
        background-color: transparent;
        color: @color7;
        transition-property: background-color;
        transition-duration: .2s;
      }

      /* See https://github.com/DerAnsari/hyprland-dots/blob/main/waybar/config */

      tooltip {
        background: @background;
        color: @color7;
        border: 1px solid @color1;
      }
      tooltip label {
        color: @color7;
      }

      #workspaces button {
        padding: 0 8px;
        background-color: transparent;
        color: @color7;
        border-bottom: 2px solid transparent;
      }
      #workspaces button.active {
        background-color: @color0;
        border-bottom: 2px solid @color1;
      }
      #workspaces button.urgent {
        background-color: @color3;
        color: @color0;
      }
      #workspaces button:hover {
        background: @color0;
      }

      #window {
        padding: 0 8px;
        color: @color7;
      }

      #pulseaudio,
      #network,
      #battery,
      #disk,
      #memory,
      #cpu,
      #temperature,
      #clock,
      #tray,
      #custom-power {
        padding: 0 8px;
        color: @color7;
      }

      #battery.warning { color: @color3; }
      #battery.critical { color: @color1; background-color: @color3; }
      #temperature.critical { color: @color7; background-color: @color3; }
      #network.disconnected { color: @color3; }
      #pulseaudio.muted { color: @color8; }

      #custom-power {
        padding: 0 12px 0 8px;
        color: @color1;
      }
    '';
  };

  assertions = [
    {
      assertion = config.services.playerctld.enable;
      message = "services.playerctld must be enabled for waybar's mpris module.";
    }
  ];

  # Waybar must start AFTER pywal renders the CSS
  systemd.user.services.waybar = {
    Unit.After = lib.mkAfter ["pywal.service"];
    Unit.Wants = lib.mkAfter ["pywal.service"];
  };
}
