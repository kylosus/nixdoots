{
  params,
  pkgs,
  ...
}: {
  time.timeZone = params.timeZone;
  i18n.defaultLocale = "en_US.UTF-8";

  programs.fish.enable = true;

  users.users = {
    ${params.username} = {
      description = params.fullname;
      shell = pkgs."${params.shell}";
      initialHashedPassword = "$y$j9T$hXOJNQ9WNOtHa2HimSNVe0$NJ/XAZoVsZ69FvuUjSVwlkAp1XAK.x.g4enqrbjJNf6";
      isNormalUser = true;
      openssh.authorizedKeys.keys = [];
      extraGroups = ["wheel" params.username];
    };
  };
}
