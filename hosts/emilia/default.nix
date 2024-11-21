{...}: {
  params = {
    system = "x86_64-linux";
    timeZone = "Europe/Istanbul";

    hostName = "Emilia";
    userName = "jokersus";
    fullName = "jokersus";

    desktop = true;

    wallpaper = ./wallpaper.png;
  };

  homeModule = {...}: {
    imports = [
      ../common/desktop.nix
      ({pkgs, ...}: {
        home.pointerCursor = {
          name = "Vanilla-DMZ";
          package = pkgs.vanilla-dmz;
          size = 64;
        };
      })
    ];

    config.host.i3 = {
      ifname = "wlan0";
      monitors = ["HDMI-A-0" "eDP"];
    };
  };
}
