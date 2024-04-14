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

      print-pipe = "cat > /dev/null";
      geometry = "80x-1";

      "perl-ext-common" = "resize-font";
      #      "perl-lib": "${config.home.profileDirectory}/lib/urxvt/perl"
    };
  };
}
