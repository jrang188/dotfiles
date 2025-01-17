{ username, ... }:
{
  wsl = {
    defaultUser = username;
    docker-desktop.enable = true;
  };
}
