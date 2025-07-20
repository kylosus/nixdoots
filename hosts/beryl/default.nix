{...}: {
  params = {
    system = "x86_64-linux";
    timeZone = "America/Chicago";

    hostName = "Beryl";
    userName = "user";
    fullName = "User";

    desktop = true;
  };

  homeModule = {...}: {
    imports = [
      ../../modules/home-manager/gui
      ../../modules/home-manager/gui/features/cursor.nix
    ];

    config.host.i3 = {
      monitors = ["HDMI-0"];
    };
  };
}
