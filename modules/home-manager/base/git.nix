{...}: {
    programs.git = {
    enable = true;
    # aliases = {
    #   co = "checkout";
    #   st = "status";
    #   dc = "diff --cached";
    #   di = "diff";
    #   br = "branch";
    #   amend = "commit --amend";
    # };
    includes = [
      # {
      #   contents = {
      #     user = {
      #       email = "mo.issa.ok@gmail.com";
      #       name = "Mohammad Issa";
      #       signingKey = "936DE6C552B5CDAF0A2DBD4428E0696214F6E298";
      #     };
      #     commit = {
      #       gpgSign = true;
      #     };
      #     init = {
      #       defaultBranch = "main";
      #     };
      #     push = {
      #       autoSetupRemote = true;
      #     };
      #   };
      # }
    ];
    }
}