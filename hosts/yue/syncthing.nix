{
  config,
  params,
  secrets,
  ...
}: let
  syncthingPath = config.services.syncthing.dataDir;
  homePath = config.users.users."${params.userName}".home;
in {
  imports = [../../modules/nixos/services/syncthing.nix];

  services.syncthing.settings = {
    devices = {
      inherit (secrets.syncthing) Emilia Phone Phone-OP Seedbox;
    };

    folders = {
      "keepass" = {
        path = "${syncthingPath}/keepass";
        devices = ["Emilia" "Phone" "Phone-OP" "Seedbox"]; # TODO: https://github.com/NixOS/nixpkgs/issues/121286
      };

      "rclone" = {
        path = "${homePath}/.config/rclone";
        devices = ["Emilia"];
      };

      "ssh_hosts" = {
        path = "${homePath}/.ssh/hosts.d";
        devices = ["Emilia"];
      };

      "phone" = {
        path = "${syncthingPath}/Phone";
        devices = ["Phone" "Phone-OP"];
      };
    };
  };

  programs.ssh.extraConfig = "include ${config.services.syncthing.settings.folders.ssh_hosts.path}";
}
