{params, ...}: {
  services.syncthing = {
    enable = true;
    user = params.userName;
    dataDir = "${config.xdg.userDirs.documents}/Syncthing";
    overrideDevices = true;
    overrideFolders = true;

    settinigs = {
      devices = {
        "device1" = { id = "123"; };
      };
    };
  };

  sops.secrets.syncthing-keys = {};
}
