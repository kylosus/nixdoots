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
        # mkdir -p /etc/secrets/initrd
        # ssh-keygen -t ed25519 -N "" -f /etc/secrets/initrd/ssh_host_key
        hostKeys = ["/etc/secrets/initrd/ssh_host_key"];
      };
    };
  };
}
