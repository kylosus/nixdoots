{
  params,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    (nerdfonts.override {fonts = ["DejaVuSansMono"];})
  ];

  programs.urxvt = {
    enable = true;

    fonts = [
      # "xft:Iosevka Nerd font Mono:size=12"
      "xft:DejaVuSansM Nerd Font:style=Regular:size=12"
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

      geometry = "80x-1";

      "perl-ext-common" = "resize-font";
      #      "perl-lib": "${config.home.profileDirectory}/lib/urxvt/perl"
    };
  };

  programs.fish = {
    enable = true;

    shellAliases = {
      vim = "${pkgs.neovim}/bin/nvim";
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
}
