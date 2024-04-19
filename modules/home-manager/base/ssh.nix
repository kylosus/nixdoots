{config, ...}: {
  # Make the secret available
  sops.secrets.ssh-hosts = {};

  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
    extraConfig = "include ${config.sops.secrets.ssh-hosts.path}";
  };
}
