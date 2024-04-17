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
    # ./neovim.nix
  ];

  programs.home-manager.enable = true;

  home = {
    username = params.username;
    homeDirectory = "/home/${params.username}";
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };

  fonts.fontconfig.enable = true;
  programs.vscode.enable = true;

  # TODO: temporary
  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
  };

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

  programs.chromium = {
    package = pkgs.ungoogled-chromium;
    enable = true;
    # Apparently doesn't work for ungoogled
    extensions = ["cjpalhdlnbpafiamejdnhcphjbkeiagm"];
  };

  programs.fish = {
    enable = true;

    shellAliases = {
      vim = "${pkgs.neovim}/bin/nvim";
      # TODO: hardcoding cat?
      ranger = "${lib.getExe pkgs.ranger} --choosedir=/tmp/.rangerdir; cd (cat /tmp/.rangerdir)";
      l = "ls -lha";
      rm = "rm -vI";
      ls = "${lib.getExe pkgs.eza} --group-directories-first --icons --classify";
      cp = "${lib.getExe pkgs.rsync} -azhvP";
    };

    #    shellAbbrs = {
    #      hm-switch = "home-manager switch --flake $HOME/docs/dots/machines/asus-ga401#mkti@jassas";
    #      nixos-switch = "sudo nixos-rebuild switch --flake $HOME/docs/dots/machines/asus-ga401#jassas";
    #    };

    plugins = [
      {
        name = "theme-agnoster";
        src = pkgs.fetchFromGitHub {
          owner = "oh-my-fish";
          repo = "theme-agnoster";
          rev = "4c5518c89ebcef393ef154c9f576a52651400d27";
          sha256 = "sha256-OFESuesnfqhXM0aij+79kdxjp4xgCt28YwTrcwQhFMU=";
        };
      }
      {
        name = "cd-ls";
        src = pkgs.fetchFromGitHub {
          owner = "fishingline";
          repo = "cd-ls";
          rev = "6133dcd09c53f9c39d0476bd4a58f4a05481e482";
          sha256 = "sha256-/7VVGZYaPbaGH2HZHMhpyMzkzZoM9/1CehijAzUlCis=";
        };
      }
    ];

    shellInit = ''
      set fish_greeting

      # Temporary
      set -gx TERM screen-256color

      set -gx SHELL ${pkgs.fish}/bin/fish

      set -gx EDITOR nvim
      set -gx BROWSER chromium

      fish_add_path -p $HOME/.local/bin
    '';
  };

  programs.atuin = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      search_mode = "fuzzy";
      style = "compact";
      inline_height = 10;
    };
    flags = [
      "--disable-up-arrow"
    ];
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
