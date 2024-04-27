# A little documentation

The idea (for now) is to just import the modules you want to use.
For example, to use mpv you can just
```nix
imports = [modules/home-manager/gui/applications/mpv];
```

Maybe this is a bit too verbose, but I'm looking into haumea for it.
I don't want to have cfgs everywhere.

### Some example config
`hosts/<hostname>/default.nix`
```nix
{...}: {
  # Parameters defining base system. Available to all modules
  params = {
    system = "x86_64-linux";
    timeZone = "Asia/Baku";

    hostName = "Hostname";
    userName = "user";
    fullName = "Userly user";

    # Enables gui
    desktop = true;
  };

  # Imported by NixOS
  module = {...}: {};

  # Imported by home-manager
  homeModule = {...}: {
    imports = [
      ../common/desktop.nix
      ../../modules/home-manager/gui/applications/mpv
    ];

    # Set some configs
    config.host.i3 = {
      monitors = ["HDMI-A-0" "eDP"];
    };
  };
}

```

# under new management

![2024-04-23_23-51](https://github.com/kylosus/nixdoots/assets/33132401/7e1eee47-fc40-4fb6-86b9-762d110f1a44)