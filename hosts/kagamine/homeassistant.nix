# TODO: Switch to https://github.com/AshleyYakeley/NixVirt
{
  config,
  pkgs,
  ...
}: let
  vmImagePath = "/var/lib/libvirt/images/haos.qcow2";
  networkXml = ''
    <network>
      <name>default</name>
      <forward mode='nat'/>
      <bridge name='virbr0' stp='on' delay='0'/>
      <ip address='10.75.0.1' netmask='255.255.255.0'>
        <dhcp>
          <range start='10.75.0.2' end='10.75.0.254'/>
        </dhcp>
      </ip>
    </network>
  '';

  domainXml = ''
    <domain type='kvm'>
      <name>nixos-vm</name>
      <memory unit='MiB'>4096</memory>
      <vcpu>2</vcpu>
      <os>
        <type arch='x86_64'>hvm</type>
        <boot dev='hd'/>
      </os>
      <devices>
        <disk type='file' device='disk'>
          <driver name='qemu' type='qcow2'/>
          <source file='${vmImagePath}'/>
          <target dev='vda' bus='virtio'/>
        </disk>
        <interface type='network'>
          <source network='default'/>
          <model type='virtio'/>
        </interface>
        <interface type='direct'>
          <source dev='wlp0s20f3' mode='bridge'/>
          <model type='virtio'/>
        </interface>
        <console type='pty'/>
      </devices>
    </domain>
  '';
in {
  environment.etc."libvirt/networks/default.xml".text = networkXml;
  environment.etc."libvirt/domains/haos-vm.xml".text = domainXml;

  systemd.services.libvirt-net-default = {
    description = "Define and start default libvirt network";
    after = ["libvirtd.service"];
    wantedBy = ["multi-user.target"];
    serviceConfig.Type = "oneshot";
    script = ''
      virsh net-define /etc/libvirt/networks/default.xml || true
      virsh net-autostart default || true
      virsh net-start default || true
    '';
  };

  systemd.services.libvirt-vm-nixos = {
    description = "Define and start nixos-vm";
    after = ["libvirt-net-default.service"];
    wantedBy = ["multi-user.target"];
    serviceConfig.Type = "oneshot";
    script = ''
      virsh define /etc/libvirt/domains/nixos-vm.xml || true
      virsh start nixos-vm || true
    '';
  };

  # Ensure image exists (you must copy it manually or declare build process)
  system.activationScripts.copyVmImage.text = ''
    if [ ! -e "${vmImagePath}" ]; then
      echo "Missing VM image at ${vmImagePath}" >&2
    fi
  '';
}
