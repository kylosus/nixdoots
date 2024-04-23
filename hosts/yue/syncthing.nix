{
  config,
  params,
  secrets,
  ...
}: {
  imports = [../../modules/nixos/services/syncthing.nix];

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

      "ssh_hosts" = {
        path = "${config.users.users."${params.userName}".home}/.ssh/hosts.d";
        devices = ["Emilia"];
      };
    };
  };

  programs.ssh.extraConfig = "include ${config.services.syncthing.settings.folders.ssh_hosts.path}";
}
