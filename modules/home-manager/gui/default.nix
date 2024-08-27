{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.host.global;
in {
  imports = [
    ./i3
    ./terminal.nix
  ];

  assertions = [
    {
      assertion = cfg.desktop;
      message = "`desktop` parameter, or the `host.global.desktop` option must be set to load this module";
    }
  ];

  # Extra files we want to place
  # For configs without configs
  home.file = {
    # How dumb is this?
    # Maybe it shuld be an override
    "${config.xdg.configHome}/keepassxc/keepassxc.ini" = lib.mkIf (builtins.elem pkgs.keepassxc config.home.packages) {
      text = ''
        [General]
        ConfigVersion=2
        GlobalAutoTypeKey=86
        GlobalAutoTypeModifiers=201326592
      '';
      recursive = true;
    };
  };

  fonts.fontconfig.enable = true;
  programs.vscode.enable = true;

  # Should be inn gui
  programs.chromium = {
    enable = true;
    package = pkgs.stable.ungoogled-chromium;
    # Apparently doesn't work for ungoogled
    extensions = ["cjpalhdlnbpafiamejdnhcphjbkeiagm"];
  };

  gtk = {
    enable = true;
    theme = {
      name = "Catppuccin-Macchiato-Compact-Pink-Dark";
      package = pkgs.catppuccin-gtk.override {
        accents = ["pink"];
        size = "compact";
        tweaks = ["rimless" "black"];
        variant = "macchiato";
      };
    };
  };

  # Now symlink the `~/.config/gtk-4.0/` folder declaratively:
  xdg.configFile = {
    "gtk-4.0/assets".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/assets";
    "gtk-4.0/gtk.css".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk.css";
    "gtk-4.0/gtk-dark.css".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk-dark.css";
  };

  services = {
    blueman-applet.enable = true;
  };

  home.packages = with pkgs; [
    firefox
    keepassxc

    # Let's have one good font
    (nerdfonts.override {fonts = ["Iosevka"];})
  ];
}
