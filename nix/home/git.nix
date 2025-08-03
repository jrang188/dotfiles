{ ... }:
{
  programs.git = {
    enable = true;
    lfs.enable = true;
    userName = "Justin Ang";
    userEmail = "justinang177@gmail.com";
    ignores = [ ".DS_Store" ];

    extraConfig = {
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      pull.ff = "only";
    };
  };
}
