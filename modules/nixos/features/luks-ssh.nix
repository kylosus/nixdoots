{
  files,
  lib,
  ...
}: {
  boot.kernelParams = ["ip=dhcp" "console=tty1"];
  boot.initrd = {
    systemd.enable = true;
    availableKernelModules = ["r8169"];
    network = {
      enable = true;
      ssh = {
        enable = true;
        port = 22;
        authorizedKeyFiles = [files.ssh-authorized];
        hostKeys = ["/etc/secrets/initrd/id_rsa"];
        shell = "/bin/cryptsetup-askpass";
      };
    };
  };
}
