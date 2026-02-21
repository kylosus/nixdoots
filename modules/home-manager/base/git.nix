{
  pkgs,
  lib,
  ...
}: {
  programs.git = lib.mkDefault {
    enable = true;
    settings = {
      user.name = "kylosus";
      user.email = "jokersus.cava@gmail.com";
    };
    signing = {
      key = "23F41BA2C877E4A3";
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
