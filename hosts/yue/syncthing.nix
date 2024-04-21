{
  config,
  params,
  secrets,
  ...
}: {
  services.syncthing.settings = {
    devices = {
      "Emilia" = {id = secrets.syncthing.Emilia;};
    };

    folders = {
      "keepass" = {
        path = "${config.services.syncthing.dataDir}/keepass";
        devices = ["Emilia"];
      };

      "rclone" = {
        path = "${config.users.users."${params.userName}".home}/.config/rclone";
        devices = ["Emilia"];
      };
    };
  };
}
