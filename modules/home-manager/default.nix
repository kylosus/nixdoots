{
  params,
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.host.global;
in {
  imports = [
    ./base
    ./secrets.nix
  ]; # (lib.optional cfg.desktop ./gui);

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

  programs.gpg = lib.mkIf cfg.desktop {
    enable = true;
  };

  services.gpg-agent = lib.mkIf cfg.desktop {
    enable = true;
    enableFishIntegration = true;
    enableBashIntegration = true;
    pinentryPackage = pkgs.pinentry-curses;
  };

  services.mpd = {
    enable = false;
    musicDirectory = "${config.xdg.userDirs.music}";
  };

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    xdg-user-dirs

    ripgrep
    fd
    zstd
    ranger

    rclone

    jq
    gron
  ];

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.11";
}
