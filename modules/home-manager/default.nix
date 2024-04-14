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
    ./i3
    ./commandline.nix
    # ./neovim.nix
    ./wal.nix
  ];

  programs.home-manager.enable = true;

  home = {
    username = params.username;
    homeDirectory = "/home/${params.username}";
  };

  # .xinitrc fix
  home.file.".xinitrc".source = ./xinitrc;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    # documents = "${config.home.homeDirectory}/docs";
    # desktop = "${config.home.homeDirectory}/desk";
    # download = "${config.home.homeDirectory}/down";
    # music = "${config.home.homeDirectory}/media/aud/music";
    # pictures = "${config.home.homeDirectory}/media/img";
    # videos = "${config.home.homeDirectory}/media/vid";
    # templates = "${config.home.homeDirectory}/docs/templates";
    # publicShare = "${config.home.homeDirectory}/docs/public";
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
    # Default is curses?
    # pinentryPackage = "curses";
  };

  programs.git = {
    enable = true;
    # aliases = {
    #   co = "checkout";
    #   st = "status";
    #   dc = "diff --cached";
    #   di = "diff";
    #   br = "branch";
    #   amend = "commit --amend";
    # };
    includes = [
      # {
      #   contents = {
      #     user = {
      #       email = "mo.issa.ok@gmail.com";
      #       name = "Mohammad Issa";
      #       signingKey = "936DE6C552B5CDAF0A2DBD4428E0696214F6E298";
      #     };
      #     commit = {
      #       gpgSign = true;
      #     };
      #     init = {
      #       defaultBranch = "main";
      #     };
      #     push = {
      #       autoSetupRemote = true;
      #     };
      #   };
      # }
    ];
  };

  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
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
        accents = [ "pink" ];
        size = "compact";
        tweaks = [ "rimless" "black" ];
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
    ungoogled-chromium
    # mpv
    # transmission
    # wl-clipboard

    xdg-user-dirs

    discord

    # bear
    # tmux

    # inkscape
    # gimp

    # texlab
    # texlive.combined.scheme-full
    # pandoc

    # rnix-lsp
    # nodePackages_latest.typescript-language-server

    # zk

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

    font-awesome_6

    (nerdfonts.override {fonts = ["Iosevka"];})
  ];

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
