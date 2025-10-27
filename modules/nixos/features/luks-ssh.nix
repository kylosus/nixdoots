{
  files,
  lib,
  ...
}: {
  boot.kernelParams = ["ip=dhcp" "console=tty1"];
  boot.initrd = {
    availableKernelModules = ["r8169" "e1000e"];
    network = {
      enable = true;
      ssh = {
        enable = true;
        port = 2222;
        authorizedKeyFiles = [files.ssh-authorized];
        # ssh-keygen -t rsa -N "" -f /etc/secrets/initrd/ssh_host_rsa_key
        hostKeys = ["/etc/secrets/initrd/ssh_host_rsa_key"];
        shell = "/bin/cryptsetup-askpass";
      };
    };
  };
}
