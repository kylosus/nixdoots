{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.host.i3;
in {
  services.polybar = {
    enable = true;
    package = pkgs.polybar.override {
      i3Support = true;
      alsaSupport = true;
      pulseSupport = true;
      nlSupport = false;
      iwSupport = true;
      mpdSupport = true;
      githubSupport = true;
    };
    config = let
      # background = "\${xrdb:color0:#222}";
      background = "#00000000";
      background-alt = "\${xrdb:color0:#222}";
      foreground = "\${xrdb:color7:#222}";
      foreground-alt = "\${xrdb:color7:#222}";
      primary = "\${xrdb:color1:#222}";
      secondary = "\${xrdb:color2:#222}";
      alert = "\${xrdb:color3:#222}";
    in {
      colors = {inherit background background-alt foreground foreground-alt alert;};

      "bar/bottom" = rec {
        bottom = true;
        width = "100%";
        height = 36;
        radius = 0;
        fixed-center = true;

        # monitor = "\${env:MONITOR:}";
        monitor = lib.lists.head cfg.monitors;
        monitor-fallback = lib.lists.tail cfg.monitors;
        # https://en.wikipedia.org/wiki/Thin_space
        separator = "|";
        inherit background foreground;

        line-size = 3;
        line-color = "#ff0";

        border-size = 0;
        border-color = "#0000000";

        # padding = 1;
        padding-left = 0;
        padding-right = 4;

        # module-margin = 0;
        module-margin-left = 3;
        module-margin-right = 3;

        font-size = "10";
        font-0 = "DejaVu Sans:style=Regular:size=${font-size}:antialias=true;1";
        font-1 = "Font Awesome 6 Free:size=${font-size};1";
        font-2 = "Font Awesome 6 Free:size=${font-size}:style=Solid;1";

        # font-0 = "monospace:style=Regular:size=${font-size};1";
        # font-1 = "DejaVu Sans:style=Regular:size=10:antialias=true;4";

        modules-left = ["i3" "xwindow"];
        # modules-center = [ "mpd" ];
        modules-right = [
          "xkeyboard"
          "pulseaudio"
          "network"
          "battery"
          "filesystem"
          "memory"
          "cpu"
          "temperature"
          #            "brillo"
          "date"
          "powermenu"
        ];

        tray-position = "right";
        tray-padding = 2;

        # tray-maxsize = 512;

        # scroll-up = "${pkgs.brillo}/bin/brillo -e -A 0.5";
        # scroll-down = "${pkgs.brillo}/bin/brillo -e -U 0.5";
      };

      "module/brillo" = {
        type = "custom/script";

        format = "<label> ";
        exec = ''echo "$(${pkgs.brillo}/bin/brillo)"%'';
        format-padding = 1;
        format-background = background;
      };

      "module/mpd" = {
        type = "internal/mpd";

        host = "127.0.0.1";
        port = "6600";
        # password = mysecretpassword

        # Awesome Font >                    
        format-online = "<label-song> <icon-prev>  <icon-seekb>  <icon-stop>  <toggle>  <icon-seekf>  <icon-next>  <icon-repeat>  <icon-random>";
        label-offline = "mpd is offline";

        label-song = " %artist% - %title%";
        # Awesome Font >                    
        icon-play = "";
        icon-pause = "";
        icon-stop = " ";
        icon-prev = "";
        icon-next = "";
        icon-seekb = "";
        icon-seekf = "";
        icon-random = "";
        icon-repeat = "";
        icon-repeatone = "";

        toggle-on-foreground = "#ff";
        toggle-off-foreground = "#55";
      };

      "module/battery" = let
        # Kinda jank
        # { ACAD = "..."; BATT = "..."; } => [ "ACAD" "BATT" ] => ... => { adapter = "ACAD"; battery = "BATT"; }
        systemBattery = builtins.sort (a: b: a < b) (builtins.attrNames (builtins.readDir /sys/class/power_supply));
        batteryConfig = builtins.listToAttrs (builtins.map (u: {
          name = u.fst;
          value = u.snd;
        }) (lib.zipLists ["adapter" "battery"] systemBattery));
      in {
        type = "internal/battery";
        full-at = 99;

        # TODO: disable this module if no battery is present
        adapter = batteryConfig.adapter or "ACAD";
        battery = batteryConfig.battery or "BATT";

        time-format = "%H:%M";
        format-charging = "<animation-charging> <label-charging>";
        format-charging-background = background;
        format-charging-padding = 1;
        format-discharging = "<ramp-capacity> <label-discharging>";
        format-discharging-background = background;
        format-discharging-padding = 1;
        format-full = "<ramp-capacity> <label-full>";
        format-full-background = background;
        format-full-padding = 1;

        label-charging = " %percentage%%";
        label-discharging = "%percentage%%";
        label-full = "%percentage%%";

        ramp-capacity-0 = "";
        ramp-capacity-1 = "";
        ramp-capacity-2 = "";
        ramp-capacity-3 = "";
        ramp-capacity-4 = "";

        # ramp-capacity-0 = " ";i
        # ramp-capacity-1 = " ";
        # ramp-capacity-2 = " ";
        # ramp-capacity-3 = " ";
        # ramp-capacity-4 = " ";

        # animation-charging-0 = " ";
        # animation-charging-1 = " ";
        # animation-charging-2 = " ";
        # animation-charging-3 = " ";
        # animation-charging-4 = " ";
        # animation-charging-framerate = 750;

        animation-charging-0 = "";
        animation-charging-1 = "";
        animation-charging-2 = "";
        animation-charging-3 = "";
        animation-charging-4 = "";
        animation-charging-framerate = 750;
      };

      "module/memory" = {
        type = "internal/memory";
        interval = 2;
        format-prefix = " ";
        format-prefix-foreground = foreground-alt;
        format-underline = "#00000000";
        label = "%percentage_used%%";
      };

      "module/date" = {
        type = "internal/date";
        interval = 1;

        date = "";
        date-alt = " %d.%m.%Y";

        time = "%H:%M:%S";
        time-alt = "%H:%M:%S";

        format-prefix = "";
        format-prefix-foreground = foreground-alt;
        format-underline = "#00000000";

        label = "%date% %time%";
      };

      "module/powermenu" = {
        type = "custom/menu";

        format-spacing = 1;

        label-open = "%{T2}";
        label-open-foreground = foreground;
        label-close = "cancel";
        label-close-foreground = primary;
        label-separator = "|";
        label-separator-foreground = foreground-alt;

        menu-0-0 = "reboot";
        menu-0-0-exec = "menu-open-1";
        menu-0-1 = "power off";
        menu-0-1-exec = "menu-open-2";

        menu-1-0 = "cancel";
        menu-1-0-exec = "menu-open-0";
        menu-1-1 = "reboot";
        menu-1-1-exec = "reboot";

        menu-2-0 = "power off";
        menu-2-0-exec = "poweroff";
        menu-2-1 = "hybernate";
        menu-2-1-exec = "systemctl suspend";
      };

      "module/i3" = rec {
        type = "internal/i3";
        format = "<label-state> <label-mode>";
        index-sort = true;
        wrapping-scroll = false;
        strip-wsnumbers = true;

        label-mode = "%mode%";
        label-mode-padding = 4;
        label-mode-foreground = foreground;
        label-mode-background = primary;

        label-focused = "%name%";
        label-focused-background = background-alt;
        label-focused-underline = primary;
        label-focused-padding = 4;

        label-unfocused = "%name%";
        label-unfocused-padding = 4;

        label-visible = "V %index%";
        label-visibile-background = label-focused-background;
        label-visible-underline = label-focused-background;
        label-visible-padding = label-focused-padding;

        label-urgent = "";
        label-urgent-background = alert;
        label-urgent-padding = 4;
      };

      "module/xwindow" = {
        type = "internal/xwindow";
        label = "%title:0:64:...%";
      };

      "module/xkeyboard" = {
        type = "internal/xkeyboard";
        blacklist-0 = "num lock";

        format-prefix = "";
        format-prefix-foreground = foreground-alt;
        format-prefix-underline = primary;

        label-layout = "";
        label-layout-underline = primary;

        label-indicator-padding = 2;
        label-indicator-margin = 1;
        label-indicator-foreground = foreground;
        label-indicator-background = primary;
        label-indicator-underline = primary;
      };

      "module/cpu" = {
        type = "internal/cpu";
        interval = 2;
        format-prefix = " ";
        format-prefix-foreground = foreground-alt;
        format-underline = "#00000000";
        label = "%percentage%%";
      };

      "module/network" = {
        type = "internal/network";

        # TODO
        interface = cfg.ifname;
        interval = 3;

        label-connected = " %downspeed%  %upspeed%";

        format-packetloss = "<animation-packetloss> <label-connected>";

        # ONly applies if <animation-packetloss> is used
        animation-packetloss-0 = "⚠";
        animation-packetloss-0-foreground = "#ffa64c";
        animation-packetloss-1 = "📶";
        animation-packetloss-1-foreground = "#000000";
        # Framerate in milliseconds
        animation-packetloss-framerate = 500;

        format-connected = "<ramp-signal> <label-connected>";
        format-connected-underline = "#00000000";

        format-disconnected = "<label-disconnected>";
        format-disconnected-underline = alert;
        label-disconnected = "xx.xx.xx.xx";
        label-disconnected-foreground = foreground-alt;

        ramp-signal-0 = "";
        ramp-signal-1 = "";
        ramp-signal-2 = "";
        ramp-signal-3 = "";
        ramp-signal-4 = "";
        ramp-signal-foreground = foreground-alt;
      };

      "module/pulseaudio" = {
        type = "internal/pulseaudio";
        format-volume = "<ramp-volume> <label-volume>";
        ramp-volume-foreground = foreground;

        ramp-volume-0 = "";
        ramp-volume-1 = "";
        ramp-volume-2 = "";

        format-muted = "<ramp-volume> <label-muted>";
        label-muted-foreground = "#55";

        # format-volume-background = background;
        # format-volume-padding = 1;
        # format-muted = "<label-muted>";
        # format-muted-background = background;
        # format-muted-padding = 1;

        # label-volume = "%percentage%%";
        # label-muted = "";

        # click-right = "pactl set-sink-mute @DEFAULT_SINK@ toggle";
        scroll-up = "pactl set-sink-volume @DEFAULT_SINK@ +1%";
        scroll-down = "pactl set-sink-volume @DEFAULT_SINK@ -1%";
      };

      "module/pulseaudio-mic" = {
        type = "internal/pulseaudio";

        sink = "@DEFAULT_AUDIO_SOURCE@";

        format-volume = "mic <ramp-volume> <label-volume>";
        ramp-volume-foreground = foreground;

        ramp-volume-0 = "";
        ramp-volume-1 = "";
        ramp-volume-2 = "";

        format-muted = "<ramp-volume> <label-muted>";
        label-muted-foreground = "#55";

        # format-volume-background = background;
        # format-volume-padding = 1;
        # format-muted = "<label-muted>";
        # format-muted-background = background;
        # format-muted-padding = 1;

        # label-volume = "%percentage%%";
        # label-muted = "";

        # click-right = "pactl set-sink-mute @DEFAULT_SINK@ toggle";
        scroll-up = "pactl set-sink-volume @DEFAULT_SINK@ +1%";
        scroll-down = "pactl set-sink-volume @DEFAULT_SINK@ -1%";
      };

      "module/filesystem" = rec {
        type = "internal/fs";
        mount-0 = "/";

        format-mounted-prefix = " ";
        format-mounted-prefix-foreground = foreground-alt;

        label-mounted = "%mountpoint% %percentage_used%%";
      };

      "module/temperature" = rec {
        type = "internal/temperature";
        interval = "0.5";

        # base-temperature = 40;
        warn-temperature = 55;
        units = true;

        format = "<ramp> <label>";
        format-underline = "#0000000";
        format-warn = "<ramp> <label-warn>";
        format-warn-unnderline = format-underline;

        format-background = background;

        label = "%temperature-c%";
        label-background = background;
        label-padding = 2;

        label-warn = label;
        label-warn-foreground = foreground;
        label-warn-background = alert;
        label-warn-padding = 2;

        ramp-0 = "";
        ramp-1 = "";
        ramp-2 = "";
        ramp-foreground = foreground-alt;
        format-warn-underline = format-underline;
      };
    };

    #script = ''
    #  for m in $(polybar --list-monitors | ${pkgs.coreutils-full}/bin/cut -d":" -f1); do
    #      MONITOR=$m polybar --reload bottom &
    #  done
    #'';

    script = "polybar --reload bottom &";
  };
}
