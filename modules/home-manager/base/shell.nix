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

    plugins = [
      {
        # TODO: replace after merged maybe
        name = "theme-agnoster";
        src = pkgs.fetchFromGitHub {
          owner = "kylosus";
          repo = "theme-agnoster";
          rev = "f906894f5101e1cf560c60e9b92ef3c026db1a8a";
          sha256 = "sha256-dqXCLRe7ZQ5gVvAraBf0P5Tc/NPcq5qMAk+GjQnjkek=";
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
      {
        name = "autopair";
        src = pkgs.fetchFromGitHub {
          owner = "jorgebucaran";
          repo = "autopair.fish";
          rev = "1.0.4";
          sha256 = "sha256-s1o188TlwpUQEN3X5MxUlD/2CFCpEkWu83U9O+wg3VU";
        };
      }
    ];

    shellInit = ''
      set fish_greeting

      # Temporary
      # set -gx TERM screen-256color

      set -gx SHELL ${pkgs.fish}/bin/fish

      set -gx EDITOR nvim
      set -gx BROWSER chromium

      fish_add_path -p $HOME/.local/bin

      # Use system packages on Arch
      set PATH $PATH $HOME/.nix-profile/bin
    '';
  };

  # sops.secrets.atuin-key = {};

  # Atuin only on desktop systems (TODO)
  # programs.atuin = lib.mkIf cfg.desktop {
  #   enable = true;
  #   enableFishIntegration = true;
  #   settings = {
  #     search_mode = "fuzzy";
  #     style = "compact";
  #     inline_height = 10;
  #
  #     auto_sync = true;
  #     sync_frequency = "5m";
  #     sync_address = "http://${secrets.nebula.ip}:8888";
  #
  #     key_path = config.sops.secrets.atuin-key.path;
  #   };
  #   flags = [
  #     "--disable-up-arrow"
  #   ];
  # };

  programs.fzf = {
    enable = true;
    enableBashIntegration = false;
    enableFishIntegration = true;
  };
}
