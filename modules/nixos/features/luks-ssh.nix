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
        # ssh-keygen -t rsa -N "" -f /etc/secrets/initrd/ssh_host_rsa_key
        hostKeys = ["/etc/secrets/initrd/ssh_host_rsa_key"];
        shell = "/bin/cryptsetup-askpass";
      };
    };
  };
}
