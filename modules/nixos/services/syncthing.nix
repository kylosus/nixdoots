{
  config,
  params,
  ...
}: {
  services.syncthing = rec {
    enable = true;
    user = params.userName;
    dataDir = "${config.users.users."${user}".home}/Syncthing";
    overrideDevices = true;
    overrideFolders = true;
  };
}
