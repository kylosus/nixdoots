{
  pkgs,
  lib,
  config,
  secrets,
  ...
}: let
  cfg = config.host.global;
in {
  programs.fish = {
    enable = true;

    shellAliases = {
      vim = lib.getExe pkgs.neovim;
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

      # Use system packages on Arch
      set PATH $PATH $HOME/.nix-profile/bin
    '';
  };

  # Atuin only on desktop systems (TODO)
  programs.atuin = lib.mkIf cfg.desktop {
    enable = true;
    enableFishIntegration = true;
    settings = {
      search_mode = "fuzzy";
      style = "compact";
      inline_height = 10;

      auto_sync = true;
      sync_frequency = "5m";
      sync_address = "http://${secrets.nebula.ip}:8888";
    };
    flags = [
      "--disable-up-arrow"
    ];
  };

  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
  };
}
