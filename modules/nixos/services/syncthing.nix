{
  config,
  params,
  secrets,
  ...
}: {
  services.syncthing = rec {
    enable = true;
    user = params.userName;
    dataDir = "${config.users.users."${user}".home}/Syncthing";
    overrideDevices = true;
    overrideFolders = true;

    settings = {
      # This is really stupid
      devices = {
        "Emilia" = {id = secrets.syncthing.Emilia;};
      };

      folders = {
        "keepass" = {
          path = "${dataDir}/keepass";
          devices = ["Emilia"];
        };
      };
    };
  };
}
