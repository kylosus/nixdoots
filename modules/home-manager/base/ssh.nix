{config, ...}: {
  # Make the secret available
  sops.secrets.ssh-hosts = {};

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    matchBlocks = {
      "*" = {
        addKeysToAgent = "yes";
        controlMaster = "no";
        controlPersist = "10m";
      };
    };

    extraConfig = ''
      # include ${config.sops.secrets.ssh-hosts.path}
      include ${config.home.homeDirectory}/.ssh/hosts.d/hosts
    '';
  };

  services.ssh-agent = {
    enable = true;
  };
}
