{
  config,
  lib,
  ...
}: {
  programs.rofi = {
    enable = true;
    # TODO
    font = "source code pro medium 10";
    terminal = lib.getExe config.programs.kitty.package;
    extraConfig = {
      modi = "drun";
      show-icons = true;
      case-sensitive = false;
    };
  };
}
