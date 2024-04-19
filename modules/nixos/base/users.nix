{
  params,
  pkgs,
  config,
  ...
}: {
  time.timeZone = params.timeZone;
  i18n.defaultLocale = "en_US.UTF-8";

  programs.fish.enable = true;

  users.users = {
    "${params.username}" = {
      description = params.fullname;
      shell = pkgs.fish;
      hashedPasswordFile = config.sops.secrets.hashedPassword.path;
      isNormalUser = true;
      openssh.authorizedKeys.keys = [];
      extraGroups = ["wheel" params.username];
    };
  };
}
