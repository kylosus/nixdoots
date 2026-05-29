{
  config,
  params,
  pkgs,
  lib,
  ...
}: let
  cfg = config.host.terminal;
in {
  options.host.terminal = {
    name = lib.mkOption {
      default = "ghostty";
      type = lib.types.enum ["urxvt" "ghostty" "kitty"];
      description = "Terminal emulator to use";
    };

    cmd = {
      spawn = lib.mkOption {
        type = lib.types.str;
        description = "Shell command that spawns a new terminal window.";
      };

      cd = lib.mkOption {
        type = lib.types.functionTo lib.types.str;
        description = "Function: directory → command that spawns a terminal in that directory.";
      };

      daemon = lib.mkOption {
        type = lib.types.str;
        description = "ExecStart for the terminal's headless / single-instance daemon (used by the X11 session).";
      };
    };

    font = {
      name = lib.mkOption {
        default = "JetBrainsMono Nerd Font";
        type = lib.types.str;
        description = "Terminal font family name";
      };
      package = lib.mkOption {
        default = pkgs.nerd-fonts.jetbrains-mono;
        type = lib.types.package;
        description = "Terminal font package to install";
      };
      size = lib.mkOption {
        default = 11;
        type = lib.types.int;
        description = "Terminal font size";
      };
    };
  };

  config = lib.mkMerge [
    {
      home.packages = [cfg.font.package];
    }

    (lib.mkIf (cfg.name == "urxvt") {
      programs.urxvt = {
        enable = true;

        package = pkgs.rxvt-unicode-unwrapped-emoji;

        fonts = [
          "xft:${cfg.font.name}:style=Regular:size=${toString cfg.font.size}"
        ];

        scroll = {
          bar.enable = false;
          lines = 1000000;
        };

        shading = 20;

        keybindings = {
          "Home" = "\\033[1~";
          "End" = "\\033[4~";
          "Control-Up" = "\\033[1;5A";
          "Control-Down" = "\\033[1;5B";
          "Control-Left" = "\\033[1;5D";
          "Control-Right" = "\\033[1;5C";
        };

        extraConfig = {
          internalBorder = 16;
          letterSpace = -1;
          scrollTtyOutput = false;
          scrollWithBuffer = false;
          scrollTtyKeypress = false;

          underlineURLs = true;

          print-pipe = "cat > /dev/null";
          geometry = "80x-1";

          "perl-ext-common" = "resize-font";
          #      "perl-lib": "${config.home.profileDirectory}/lib/urxvt/perl"
        };
      };

      host.terminal.cmd = {
        spawn = "${config.programs.urxvt.package}/bin/urxvtc";
        cd = dir: ''${config.programs.urxvt.package}/bin/urxvtc -cd "${dir}"'';
        daemon = "${config.programs.urxvt.package}/bin/urxvtd -o -q";
      };
    })

    (lib.mkIf (cfg.name == "ghostty") {
      programs.ghostty = {
        enable = true;

        package = pkgs.stable.ghostty;

        enableFishIntegration = true;

        # enableVimSyntax = true;

        settings = {
          # Colors
          config-file = "${config.xdg.cacheHome}/wal/ghostty.conf";

          font-family = cfg.font.name;
          font-size = cfg.font.size;
          adjust-cell-width = -1;

          # Get rid of the ugly window deco and use i3's defaults
          window-padding-x = 8;
          window-padding-y = 8;
          window-decoration = "server";
          gtk-titlebar = false;
          background-opacity = 0.9;

          # Multiple windows
          quit-after-last-window-closed = false;
          window-inherit-working-directory = false;

          # Qol
          link-url = true;
          copy-on-select = true;

          shell-integration-features = ["no-path" "ssh-env" "ssh-terminfo"];
        };
      };

      host.terminal.cmd = {
        spawn = "${lib.getExe config.programs.ghostty.package} +new-window";
        cd = dir: ''${lib.getExe config.programs.ghostty.package} +new-window --working-directory="${dir}"'';
        daemon = "${lib.getExe config.programs.ghostty.package} --gtk-single-instance=true --initial-window=false";
      };
    })

    (lib.mkIf (cfg.name == "kitty") {
      programs.kitty = {
        enable = true;

        font = {
          name = cfg.font.name;
          size = cfg.font.size;
        };

        settings = {
          # Allow i3 to handle borders/decorations
          linux_display_server = "x11";
          window_padding_width = 8;
          background_opacity = "0.9";
          confirm_os_window_close = 0;

          # Makes fonts not bold
          text_composition_strategy = "legacy";

          # Qol
          scrollback_lines = 1000000;
          copy_on_select = true;
          detect_urls = true;

          # Fast startup
          single_instance = true;
        };

        keybindings = {
          "print_screen" = "discard_event";
          "shift+print_screen" = "discard_event";
          # "scroll_lock" = "discard_event";
          # "pause" = "discard_event";
          # "insert" = "discard_event";

          # Scope zoom to current window only
          "ctrl+shift+equal" = "change_font_size current +1.0";
          "ctrl+shift+minus" = "change_font_size current -1.0";
          "ctrl+shift+backspace" = "change_font_size current 0";
        };

        shellIntegration.enableFishIntegration = false;
      };

      host.terminal.cmd = {
        spawn = "${lib.getExe config.programs.kitty.package} --single-instance";
        cd = dir: ''${lib.getExe config.programs.kitty.package} --single-instance --directory "${dir}"'';
        daemon = "${lib.getExe config.programs.kitty.package} --single-instance --start-as=hidden";
      };
    })
  ];
}
