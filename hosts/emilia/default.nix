{...}: {
  params = {
    system = "x86_64-linux";
    timeZone = "Europe/Istanbul";

    hostName = "Emilia";
    username = "jokersus";
    fullname = "jokersus";
  };

  homeModule = {...}: {
    imports = [../common/desktop.nix];

    config.host.i3 = {
      monitors = ["HDMI-A-0" "eDP"];
    };
  };
}
