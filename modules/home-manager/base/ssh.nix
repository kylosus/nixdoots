{config, ...}: {
  # Make the secret available
  sops.secrets.ssh-hosts = {};

  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
    controlMaster = "yes";
    controlPersist = "10m";
    extraConfig = ''
      # include ${config.sops.secrets.ssh-hosts.path}
      include ${config.home.homeDirectory}/.ssh/hosts.d/hosts
    '';
  };

  services.ssh-agent = {
    enable = true;
  };
}
