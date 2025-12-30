_:
{
  programs.git = {
    enable = true;
    lfs.enable = true;
    settings = {
      user = {
        name = "Justin Ang";
        email = "justinang177@gmail.com";
      };
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      pull.ff = "only";
    };
    ignores = [ ".DS_Store" ];
  };
}
