{
  pkgs,
  config,
  params,
  lib,
  ...
}: let
  cfg = config.host.global;
  wm = params.windowManager or "i3";
  isWayland = wm == "hyprland";
in {
  imports =
    [
      ./shared
      ./terminal.nix
    ]
    ++ lib.optional (wm == "i3") ./i3
    ++ lib.optional (wm == "hyprland") ./hyprland;

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

  programs.chromium = {
    enable = true;
    package = pkgs.stable.ungoogled-chromium;

    commandLineArgs = lib.mkIf isWayland ["--ozone-platform=wayland"];
  };

  gtk = {
    enable = true;
    theme = {
      name = "Dracula";
      package = pkgs.dracula-theme;
      # package = pkgs.catppuccin-gtk.override {
      #   accents = ["pink"];
      #   size = "compact";
      #   tweaks = ["rimless" "black"];
      #  variant = "macchiato";
      # };
    };
  };

  services = {
    blueman-applet = {
      enable = true;
    };
  };

  home.packages = with pkgs; [
    firefox
    keepassxc

    # CJK fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif

    # Let's have one good font
    nerd-fonts.iosevka
  ];
}
