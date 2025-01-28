{
  files,
  lib,
  ...
}: {
  boot.kernelParams = ["ip=dhcp"];
  boot.initrd = {
    systemd.users.root.shell = "/bin/cryptsetup-askpass";
    network = {
      enable = true;
      ssh = {
        enable = true;
        port = 22;
        authorizedKeyFiles = [files.ssh-authorized];
        hostKeys = ["/etc/secrets/initrd/id_rsa"];
      };
    };
  };
}
