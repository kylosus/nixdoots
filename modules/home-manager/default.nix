{
  params,
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./base
    ./secrets.nix
  ];

  programs.home-manager.enable = true;

  home = {
    username = params.userName;
    homeDirectory = "/home/${params.userName}";
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };

  fonts.fontconfig.enable = true;
  programs.vscode.enable = true;

  programs.gpg = {
    enable = true;
    homedir = "${config.xdg.dataHome}/gnupg";
  };

  services.gpg-agent = {
    enable = true;
    enableFishIntegration = true;
    enableBashIntegration = true;
    pinentryPackage = pkgs.pinentry-curses;
  };

  programs.chromium = {
    package = pkgs.ungoogled-chromium;
    enable = true;
    # Apparently doesn't work for ungoogled
    extensions = ["cjpalhdlnbpafiamejdnhcphjbkeiagm"];
  };

  services.mpd = {
    enable = true;
    musicDirectory = "${config.xdg.userDirs.music}";
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

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    firefox
    # chromium
    # mpv
    # transmission
    # wl-clipboard

    xdg-user-dirs

    discord

    # inkscape
    # gimp

    # texlab
    # texlive.combined.scheme-full
    # pandoc

    # rnix-lsp
    # nodePackages_latest.typescript-language-server

    # glow
    # hyperfine

    neovim

    # file
    # du-dust
    ripgrep
    fd
    zstd
    ranger

    jq
    gron

    # gnomeExtensions.blur-my-shell

    # Waiting for 273808 github issue merge into 23.11 (if it is to be backported)
    # unstable.supergfxctl
    # unstable.asusctl
    # unstable.neovim
    # unstable.ollama

    # appimage-run
    # nix-alien

    # Let's have one good font
    (nerdfonts.override {fonts = ["Iosevka"];})
  ];

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.11";
}
