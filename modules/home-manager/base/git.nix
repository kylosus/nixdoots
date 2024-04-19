{
  pkgs,
  lib,
  ...
}: {
  programs.git = {
    enable = true;
    userName = "kylosus";
    userEmail = "jokersus.cava@gmail.com";
    signing = {
      key = "3F20398966883CBB154D52FBAAB80482FD6F2154";
      signByDefault = true;
    };

    includes = [
      {
        contents = {
          commit.verbose = true;
          merge.tool = "${lib.getBin pkgs.vim}/bin/vimdiff";
        };
      }
    ];
  };
}
