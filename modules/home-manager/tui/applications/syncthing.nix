{config, ...}: {
  services.syncthing = {
    enable = false;
    # dataDir = "${config.xdg.userDirs.documents}/Syncthing";
    # overrideDevices = true;
    # overrideFolders = true;
  };
}
